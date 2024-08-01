# t_array

@testset verbose = true "TimeArray modification" begin
    @testset "Case №1: Replace TimeTick's" begin
    a = TimeArray([
        TimeTick(Time(1), -2.0),
        TimeTick(Time(2), -4.0),
        TimeTick(Time(3), -6.0),
    ])

    @test replace(
        x -> -2.0x,
        TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 2.0),
            TimeTick(Time(3), 3.0),
        ]),
    ) == a
    end
    @testset "Case №2: Replacing NaN's" begin
        a = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
        ])

        @test replace(TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), 1.0),
        ]), NaN => 1.0) == a

        @test replace(TimeArray([
            TimeTick(Time(1), NaN),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), NaN),
        ]), NaN => 1.0) == a
    end

    @testset "Case №3: Fill methods" begin
        ta_nan = TimeArray{Time,Float64}([
            (Time(1), 5),
            (Time(2), NaN),
            (Time(3), 3),
            (Time(4), Inf),
            (Time(5), 7),
            (Time(6), Inf),
            (Time(7), NaN),
            (Time(8), 10),
        ])

        @test isequal(TimeArray{Time,Float64}([
            TimeTick(Time(1), 5.0),
            TimeTick(Time(2), 3.0),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), Inf),
            TimeTick(Time(5), 7.0),
            TimeTick(Time(6), Inf),
            TimeTick(Time(7), 10.0),
            TimeTick(Time(8), 10.0),
        ]),
        ta_forward_fill(ta_nan),
        )

        @test isequal(TimeArray{Time,Float64}([
            TimeTick(Time(1), 5.0),
            TimeTick(Time(2), 5.0),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), Inf),
            TimeTick(Time(5), 7.0),
            TimeTick(Time(6), Inf),
            TimeTick(Time(7), Inf),
            TimeTick(Time(8), 10.0),
        ]),
        ta_backward_fill(ta_nan),
        )
        
        @test isequal(TimeArray{Time,Float64}([
            TimeTick(Time(1), 5.0),
            TimeTick(Time(2), 4.0),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), Inf),
            TimeTick(Time(5), 7.0),
            TimeTick(Time(6), Inf),
            TimeTick(Time(7), NaN),
            TimeTick(Time(8), 10.0),
        ]),
        ta_linear_fill(ta_nan),
        )
        
        @test isequal(TimeArray{Time,Float64}([
            TimeTick(Time(1), 5.0),
            TimeTick(Time(2), 3.0),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), 7.0),
            TimeTick(Time(5), 7.0),
            TimeTick(Time(6), 10.0),
            TimeTick(Time(7), 10.0),
            TimeTick(Time(8), 10.0),
        ]),
        ta_forward_fill(x -> isinf(x) || isnan(x), ta_nan),
        )

        @test isequal(TimeArray{Time,Float64}([
            TimeTick(Time(1), 5.0),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), 7.0),
            TimeTick(Time(5), 7.0),
            TimeTick(Time(6), NaN),
            TimeTick(Time(7), NaN),
            TimeTick(Time(8), 10.0),
        ]),
        ta_forward_fill(isinf, ta_nan),
        )
    end

    @testset "Case №1: Append method" begin
        a = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
        ])

        new_values = [
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
        ]

        append!(a, new_values)

        @test a == TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
            TimeTick(Time(3), 1.0),
        ])

        new_values2 = [
            TimeTick(Time(3), 3.0),
            TimeTick(Time(5), 5.0),
            TimeTick(Time(4), 1.8),
        ]

        append!(a, new_values2)

        @test a == TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
            TimeTick(Time(3), 1.0),
            TimeTick(Time(3), 3.0),
            TimeTick(Time(4), 1.8),
            TimeTick(Time(5), 5.0),
        ])
    end

    @testset "Case №1: Vcat method" begin
        a = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
        ])

        b = TimeArray([
            TimeTick(Time(4), 3.0),
            TimeTick(Time(5), 3.0),
            TimeTick(Time(6), 3.0),
        ])

        @test vcat(a, b) == TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
            TimeTick(Time(4), 3.0),
            TimeTick(Time(5), 3.0),
            TimeTick(Time(6), 3.0),
        ])

        c = TimeArray([
            TimeTick(Time(1), 3.0),
            TimeTick(Time(3), 5.0),
            TimeTick(Time(2), 1.0),
        ])

        @test vcat(a, c) == TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(1), 3.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
            TimeTick(Time(3), 5.0),
        ])
    end

    @testset "Case №1: Vcat method" begin
        a = TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 1.0),
            TimeTick(Time(3), 1.0),
        ])

        @test isequal(cumsum(a), TimeArray([
            TimeTick(Time(1), 1.0),
            TimeTick(Time(2), 2.0),
            TimeTick(Time(3), 3.0),
        ]))

        b = TimeArray([
            TimeTick(Time(1), 3.0),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), 4.0),
        ])

        @test isequal(cumsum(b), TimeArray([
            TimeTick(Time(1), 3.0),
            TimeTick(Time(2), NaN),
            TimeTick(Time(3), NaN),
        ]))
    end
end
