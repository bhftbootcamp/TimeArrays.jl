# math

@testset verbose = true "Merge TimeArrays" begin

    left = TimeArray([
        TimeTick(Time(1), 1.0),
        TimeTick(Time(3), -2.0),
        TimeTick(Time(4), 0.0),
    ])

    right = TimeArray([
        TimeTick(Time(2), -1.0),
        TimeTick(Time(3), 0.0),
        TimeTick(Time(5), 3.0),
    ])

    @testset "Case №1: Custom merge functions" begin
        merged_max = TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 0.0),
            TimeTick(Time(4), 0.0),
            TimeTick(Time(5), 3.0),
        ])

        @test isequal(merged_max, ta_mergewith(max, left, right))

        merged_min = TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(2), -1.0),
            TimeTick(Time(3), -2.0),
            TimeTick(Time(4), 0.0),
            TimeTick(Time(5), 0.0),
        ])

        @test isequal(merged_min, ta_mergewith(min, left, right))

        merged_avg = TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(2), 0.0),
            TimeTick(Time(3), -1.0),
            TimeTick(Time(4), 0.0),
            TimeTick(Time(5), 1.5),
        ])

        @test isequal(merged_avg, ta_mergewith((x, y) -> (x + y) / 2.0, left, right))

        merged_nan = TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), NaN),
            TimeTick(Time(4), NaN),
            TimeTick(Time(5), NaN),
        ])

        @test isequal(merged_nan, ta_mergewith((x, y) -> NaN, left, right))
    end

    @testset "Case №2: Merge left timestamps" begin
        left_avg = TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(3), -1.0),
            TimeTick(Time(4), 0.0),
        ])

        @test isequal(left_avg, ta_mergewith((x, y) -> (x + y) / 2.0, left, right, r_merge = false))
    end

    @testset "Case №3: Merge right timestamps" begin
        right_avg = TimeArray([
            TimeTick(Time(2), 0.0),
            TimeTick(Time(3), -1.0),
            TimeTick(Time(5), 1.5),
        ])

        @test isequal(right_avg, ta_mergewith((x, y) -> (x + y) / 2.0, left, right, l_merge = false))
    end
end

@testset verbose = true "Base arithmetic" begin

    a = TimeArray([
        TimeTick(Time(2), 1.0),
        TimeTick(Time(4), 2.0),
        TimeTick(Time(6), 3.0),
    ])

    @testset verbose = true "Scalar arithmetic" begin
        
        value = 2.0
        @testset "Case №1: Plus" begin
            a_plus_value = TimeArray([
                TimeTick(Time(2), 3.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 5.0),
            ])
            
            @test isequal(a_plus_value, a + value)
        end

        @testset "Case №2: Minus" begin
            a_minus_value = TimeArray([
                TimeTick(Time(2), -1.0),
                TimeTick(Time(4), 0.0),
                TimeTick(Time(6), 1.0),
            ])

            @test isequal(a_minus_value, a - value)
        end

        @testset "Case №3: Multiply" begin
            a_mul_value = TimeArray([
                TimeTick(Time(2), 2.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 6.0),
            ])

            @test isequal(a_mul_value, a * value)
        end

        @testset "Case №4: Division" begin
            a_div_value = TimeArray([
                TimeTick(Time(2), 0.5),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(6), 3.0/2.0),
            ])

            @test isequal(a_div_value, a / value)
        end
    end

    @testset verbose = true "Identical timestamps" begin
        @testset "Case №1: Plus" begin
            a_plus_a = TimeArray([
                TimeTick(Time(2), 2.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 6.0),
            ])
            
            @test isequal(a_plus_a, ta_mergewith(+, a, a))
            @test isequal(a_plus_a, a + a)
        end

        @testset "Case №2: Minus" begin
            a_minus_a = TimeArray([
                TimeTick(Time(2), 0.0),
                TimeTick(Time(4), 0.0),
                TimeTick(Time(6), 0.0),
            ])

            @test isequal(a_minus_a, ta_mergewith(-, a, a))
            @test isequal(a_minus_a, a - a)
        end

        @testset "Case №3: Multiply" begin
            a_mul_a = TimeArray([
                TimeTick(Time(2), 1.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 9.0),
            ])

            @test isequal(a_mul_a, ta_mergewith(*, a, a))
            @test isequal(a_mul_a, a * a)
        end

        @testset "Case №4: Division" begin
            a_div_a = TimeArray([
                TimeTick(Time(2), 1.0),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(6), 1.0),
            ])

            @test isequal(a_div_a, ta_mergewith(/, a, a))
            @test isequal(a_div_a, a / a)
        end
    end

    @testset verbose = true "Shifted forward timestamps" begin

        b = TimeArray([
            TimeTick(Time(3), 1.0),
            TimeTick(Time(5), 2.0),
            TimeTick(Time(7), 3.0),
        ])

        @testset "Case №1: Plus" begin
            a_plus_b = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 2.0),
                TimeTick(Time(4), 3.0),
                TimeTick(Time(5), 4.0),
                TimeTick(Time(6), 5.0),
                TimeTick(Time(7), 6.0),
            ])
            
            @test isequal(a_plus_b, ta_mergewith(+, a, b))
            @test isequal(a_plus_b, a + b)
        end

        @testset "Case №2: Minus" begin
            a_minus_b = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 0.0),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(5), 0.0),
                TimeTick(Time(6), 1.0),
                TimeTick(Time(7), 0.0),
            ])

            @test isequal(a_minus_b, ta_mergewith(-, a, b))
            @test isequal(a_minus_b, a - b)
        end

        @testset "Case №3: Multiply" begin
            a_mul_b = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 1.0),
                TimeTick(Time(4), 2.0),
                TimeTick(Time(5), 4.0),
                TimeTick(Time(6), 6.0),
                TimeTick(Time(7), 9.0),
            ])

            @test isequal(a_mul_b, ta_mergewith(*, a, b))
            @test isequal(a_mul_b, a * b)
        end

        @testset "Case №4: Division" begin
            a_div_b = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 1.0),
                TimeTick(Time(4), 2.0),
                TimeTick(Time(5), 1.0),
                TimeTick(Time(6), 1.5),
                TimeTick(Time(7), 1.0),
            ])

            @test isequal(a_div_b, ta_mergewith(/, a, b))
            @test isequal(a_div_b, a / b)
        end
    end

    @testset verbose = true "Shifted backward timestamps" begin

        c = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(3), 2.0),
            TimeTick(Time(5), 3.0),
        ])

        @testset "Case №1: Plus" begin
            a_plus_c = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 2.0),
                TimeTick(Time(3), 3.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(5), 5.0),
                TimeTick(Time(6), 6.0),
            ])
            
            @test isequal(a_plus_c, ta_mergewith(+, a, c))
            @test isequal(a_plus_c, a + c)
        end

        @testset "Case №2: Minus" begin
            a_minus_c = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 0.0),
                TimeTick(Time(3), -1.0),
                TimeTick(Time(4), 0.0),
                TimeTick(Time(5), -1.0),
                TimeTick(Time(6), 0.0),
            ])

            @test isequal(a_minus_c, ta_mergewith(-, a, c))
            @test isequal(a_minus_c, a - c)
        end

        @testset "Case №3: Multiply" begin
            a_mul_c = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 1.0),
                TimeTick(Time(3), 2.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(5), 6.0),
                TimeTick(Time(6), 9.0),
            ])

            @test isequal(a_mul_c, ta_mergewith(*, a, c))
            @test isequal(a_mul_c, a * c)
        end

        @testset "Case №4: Division" begin
            a_div_c = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 1.0),
                TimeTick(Time(3), 0.5),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(5), 2/3),
                TimeTick(Time(6), 1.0),
            ])

            @test isequal(a_div_c, ta_mergewith(/, a, c))
            @test isequal(a_div_c, a / c)
        end
    end

    @testset verbose = true "Outer bounds timestamps" begin

        d = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(4), 2.0),
            TimeTick(Time(7), 3.0),
        ])

        @testset "Case №1: Plus" begin
            a_plus_d = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 2.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 5.0),
                TimeTick(Time(7), 6.0),
            ])
            
            @test isequal(a_plus_d, ta_mergewith(+, a, d))
            @test isequal(a_plus_d, a + d)
        end

        @testset "Case №2: Minus" begin
            a_minus_d = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 0.0),
                TimeTick(Time(4), 0.0),
                TimeTick(Time(6), 1.0),
                TimeTick(Time(7), 0.0),
            ])

            @test isequal(a_minus_d, ta_mergewith(-, a, d))
            @test isequal(a_minus_d, a - d)
        end

        @testset "Case №3: Multiply" begin
            a_mul_d = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 1.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(6), 6.0),
                TimeTick(Time(7), 9.0),
            ])

            @test isequal(a_mul_d, ta_mergewith(*, a, d))
            @test isequal(a_mul_d, a * d)
        end

        @testset "Case №4: Division" begin
            a_div_d = TimeArray([
                TimeTick(Time(1), NaN),
                TimeTick(Time(2), 1.0),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(6), 1.5),
                TimeTick(Time(7), 1.0),
            ])

            @test isequal(a_div_d, ta_mergewith(/, a, d))
            @test isequal(a_div_d, a / d)
        end
    end

    @testset verbose = true "Inner bounds timestamps" begin

        e = TimeArray([
            TimeTick(Time(3), 1.0),
            TimeTick(Time(4), 2.0),
            TimeTick(Time(5), 3.0),
        ])

        @testset "Case №1: Plus" begin
            a_plus_e = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 2.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(5), 5.0),
                TimeTick(Time(6), 6.0),
            ])
            
            @test isequal(a_plus_e, ta_mergewith(+, a, e))
            @test isequal(a_plus_e, a + e)
        end

        @testset "Case №2: Minus" begin
            a_minus_e = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 0.0),
                TimeTick(Time(4), 0.0),
                TimeTick(Time(5), -1.0),
                TimeTick(Time(6), 0.0),
            ])

            @test isequal(a_minus_e, ta_mergewith(-, a, e))
            @test isequal(a_minus_e, a - e)
        end

        @testset "Case №3: Multiply" begin
            a_mul_e = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 1.0),
                TimeTick(Time(4), 4.0),
                TimeTick(Time(5), 6.0),
                TimeTick(Time(6), 9.0),
            ])

            @test isequal(a_mul_e, ta_mergewith(*, a, e))
            @test isequal(a_mul_e, a * e)
        end

        @testset "Case №4: Division" begin
            a_div_e = TimeArray([
                TimeTick(Time(2), NaN),
                TimeTick(Time(3), 1.0),
                TimeTick(Time(4), 1.0),
                TimeTick(Time(5), 2/3),
                TimeTick(Time(6), 1.0),
            ])

            @test isequal(a_div_e, ta_mergewith(/, a, e))
            @test isequal(a_div_e, a / e)
        end
    end
end
