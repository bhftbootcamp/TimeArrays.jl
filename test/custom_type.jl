# custom_type

@testset verbose = true "Custom type TimeTick" begin

    struct OHLC
        o::Float64
        h::Float64
        l::Float64
        c::Float64
    end

    # Interface
    Base.isless(left::OHLC, right::OHLC) = left.h < right.h
    TimeArrays.ta_nan(::Type{OHLC}) = OHLC(NaN, NaN, NaN, NaN)
    Base.isnan(x::OHLC) = isnan(x.o) && isnan(x.h) && isnan(x.l) && isnan(x.c)
    Base.zero(::Type{OHLC}) = OHLC(0.0, 0.0, 0.0, 0.0)

    function merge_ohlc(left, right)
        return OHLC(left.o + right.o, left.h - left.h, left.l * right.l, left.c / right.c)
    end

    Base.:/(left::Number, right::OHLC) = OHLC(left / right.o, left / right.h, left / right.l, left / right.c)
    Base.:/(left::OHLC, right::Number) = OHLC(left.o / right, left.h / right, left.l / right, left.c / right)

    @testset "Case №1: Merge functions" begin
        left = TimeArray([
            TimeTick(DateTime(2024, 1, 1, 1), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 2), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 3), OHLC(1, 2, 3, 4)),
        ])

        right = TimeArray([
            TimeTick(DateTime(2024, 1, 1, 2), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 3), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 4), OHLC(1, 2, 3, 4)),
        ])

        @test isequal(
            ta_mergewith(merge_ohlc, left, right),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 1), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(2.0, 0.0, 9.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(2.0, 0.0, 9.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(2.0, 0.0, 9.0, 1.0)),
            ]),
        )
    end

    Base.:+(left::OHLC, right::OHLC) = OHLC(left.o + right.o, left.h + right.h, left.l + right.l, left.c + right.c)
    Base.:-(left::OHLC, right::OHLC) = OHLC(left.o - right.o, left.h - right.h, left.l - right.l, left.c - right.c)
    Base.:*(left::OHLC, right::OHLC) = OHLC(left.o * right.o, left.h * right.h, left.l * right.l, left.c * right.c)
    Base.:*(left::Number, right::OHLC) = OHLC(left * right.o, left * right.h, left * right.l, left * right.c)
    Base.:*(left::OHLC, right::Number) = right * left

    @testset "Case №2: Fill functions" begin
        ta_nan = TimeArray([
            TimeTick(DateTime(2024, 1, 1, 2), OHLC(1, 1, 1, 1)),
            TimeTick(DateTime(2024, 1, 1, 3), OHLC(NaN, NaN, NaN, NaN)),
            TimeTick(DateTime(2024, 1, 1, 4), OHLC(NaN, NaN, NaN, NaN)),
            TimeTick(DateTime(2024, 1, 1, 5), OHLC(10, 10, 10, 10)),
        ])

        @test isequal(
            ta_forward_fill(ta_nan),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(1.0, 1.0, 1.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(10.0, 10.0, 10.0, 10.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(10.0, 10.0, 10.0, 10.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(10.0, 10.0, 10.0, 10.0)),
            ]),
        )

        @test isequal(
            ta_backward_fill(ta_nan),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(1.0, 1.0, 1.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(1.0, 1.0, 1.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(1.0, 1.0, 1.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(10.0, 10.0, 10.0, 10.0)),
            ]),
        )

        @test isequal(
            ta_linear_fill(ta_nan),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(1.0, 1.0, 1.0, 1.0)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(4.0, 4.0, 4.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(7.0, 7.0, 7.0, 7.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(10.0, 10.0, 10.0, 10.0)),
            ]),
        )
    end

    @testset "Case №3: Window functions" begin
        ta_ohlc = TimeArray([
            TimeTick(DateTime(2024, 1, 1, 1), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 2), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 3), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 4), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 5), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 6), OHLC(1, 2, 3, 4)),
        ])

        @test isequal(
            ta_lag(ta_ohlc, 3),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 1), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 6), OHLC(1.0, 2.0, 3.0, 4.0)),
            ]),
        )

        @test isequal(
            ta_sma(ta_ohlc, 3),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 1), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 6), OHLC(1.0, 2.0, 3.0, 4.0)),
            ]),
        )

        @test isequal(
            ta_rolling(sum, ta_ohlc, 3),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 1), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 6), OHLC(3.0, 6.0, 9.0, 12.0)),
            ]),
        )

        @test isequal(
            ta_rolling(sum, ta_ohlc, 3; observations = 1),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 1), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(2.0, 4.0, 6.0, 8.0)),
                TimeTick(DateTime(2024, 1, 1, 3), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 5), OHLC(3.0, 6.0, 9.0, 12.0)),
                TimeTick(DateTime(2024, 1, 1, 6), OHLC(3.0, 6.0, 9.0, 12.0)),
            ]),
        )
    end

    @testset "Case №4: Resample functions" begin

        ta_ohlc = TimeArray([
            TimeTick(DateTime(2024, 1, 1, 1), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 2), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 3), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 4), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 5), OHLC(1, 2, 3, 4)),
            TimeTick(DateTime(2024, 1, 1, 6), OHLC(1, 2, 3, 4)),
        ])

        @test isequal(
            ta_resample(sum, ta_ohlc, Hour(2)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 0), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 2), OHLC(2.0, 4.0, 6.0, 8.0)),
                TimeTick(DateTime(2024, 1, 1, 4), OHLC(2.0, 4.0, 6.0, 8.0)),
                TimeTick(DateTime(2024, 1, 1, 6), OHLC(1.0, 2.0, 3.0, 4.0)),
            ]),
        )

        @test isequal(
            ta_resample(x -> isempty(x) ? TimeArrays.ta_nan(x) : maximum(x), ta_ohlc, Minute(40)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 0, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 1, 20), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 2,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 2, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 3, 20), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 4,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 4, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 5, 20), OHLC(NaN, NaN, NaN, NaN)),
                TimeTick(DateTime(2024, 1, 1, 6,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
            ]),
        )

        @test isequal(
            ta_resample(sum, ta_ohlc, Minute(40)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1, 0, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 1, 20), OHLC(0.0, 0.0, 0.0, 0.0)),
                TimeTick(DateTime(2024, 1, 1, 2,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 2, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 3, 20), OHLC(0.0, 0.0, 0.0, 0.0)),
                TimeTick(DateTime(2024, 1, 1, 4,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 4, 40), OHLC(1.0, 2.0, 3.0, 4.0)),
                TimeTick(DateTime(2024, 1, 1, 5, 20), OHLC(0.0, 0.0, 0.0, 0.0)),
                TimeTick(DateTime(2024, 1, 1, 6,  0), OHLC(1.0, 2.0, 3.0, 4.0)),
            ]),
        )
    end
end
