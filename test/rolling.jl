# rolling

@testset verbose = true "" begin
    @testset "Case №1: Fixed window" begin
        ta_for_window = TimeArray([
            TimeTick(DateTime(2024, 1, 1), 1.0),
            TimeTick(DateTime(2024, 1, 2), 2.0),
            TimeTick(DateTime(2024, 1, 5), 3.0),
            TimeTick(DateTime(2024, 1, 6), 4.0),
            TimeTick(DateTime(2024, 1, 7), 5.0),
            TimeTick(DateTime(2024, 1, 15), 6.0),
        ])

        @test isequal(
            ta_rolling(sum, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 10.0),
            TimeTick(DateTime(2024, 1, 7), 14.0),
            TimeTick(DateTime(2024, 1, 15), 18.0),
        ]),
        )

        @test isequal(
            ta_rolling(mean, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 2.5),
            TimeTick(DateTime(2024, 1, 7), 3.5),
            TimeTick(DateTime(2024, 1, 15), 4.5),
        ]),
        )

        @test isequal(
            ta_rolling(maximum, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 4.0),
            TimeTick(DateTime(2024, 1, 7), 5.0),
            TimeTick(DateTime(2024, 1, 15), 6.0),
        ]),
        )

        @test isequal(
            ta_rolling(minimum, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 1.0),
            TimeTick(DateTime(2024, 1, 7), 2.0),
            TimeTick(DateTime(2024, 1, 15), 3.0),
        ]),
        )

        @test isequal(
            ta_rolling(first, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 1.0),
            TimeTick(DateTime(2024, 1, 7), 2.0),
            TimeTick(DateTime(2024, 1, 15), 3.0),
        ]),
        )

        @test isequal(
            ta_rolling(last, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 4.0),
            TimeTick(DateTime(2024, 1, 7), 5.0),
            TimeTick(DateTime(2024, 1, 15), 6.0),
        ]),
        )

        @test isequal(
            ta_rolling(median, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 2.5),
            TimeTick(DateTime(2024, 1, 7), 3.5),
            TimeTick(DateTime(2024, 1, 15), 4.5),
        ]),
        )

        @test isequal(
            ta_rolling(std, ta_for_window, 4),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), 1.2909944487358056),
            TimeTick(DateTime(2024, 1, 7), 1.2909944487358056),
            TimeTick(DateTime(2024, 1, 15), 1.2909944487358056),
        ]),
        )
    end

    @testset "Case №2: Periodic window" begin
        ta_for_window = TimeArray([
            TimeTick(DateTime(2024, 1, 1), 1.0),
            TimeTick(DateTime(2024, 1, 2), 2.0),
            TimeTick(DateTime(2024, 1, 5), 3.0),
            TimeTick(DateTime(2024, 1, 6), 4.0),
            TimeTick(DateTime(2024, 1, 7), 5.0),
            TimeTick(DateTime(2024, 1, 15), 6.0),
        ])

        @test isequal(
            ta_rolling(sum, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 3.0),
                TimeTick(DateTime(2024, 1, 5), 5.0),
                TimeTick(DateTime(2024, 1, 6), 7.0),
                TimeTick(DateTime(2024, 1, 7), 12.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(mean, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 1.5),
                TimeTick(DateTime(2024, 1, 5), 2.5),
                TimeTick(DateTime(2024, 1, 6), 3.5),
                TimeTick(DateTime(2024, 1, 7), 4.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(maximum, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 2.0),
                TimeTick(DateTime(2024, 1, 5), 3.0),
                TimeTick(DateTime(2024, 1, 6), 4.0),
                TimeTick(DateTime(2024, 1, 7), 5.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(minimum, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 1.0),
                TimeTick(DateTime(2024, 1, 5), 2.0),
                TimeTick(DateTime(2024, 1, 6), 3.0),
                TimeTick(DateTime(2024, 1, 7), 3.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(first, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 1.0),
                TimeTick(DateTime(2024, 1, 5), 2.0),
                TimeTick(DateTime(2024, 1, 6), 3.0),
                TimeTick(DateTime(2024, 1, 7), 3.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(last, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 2.0),
                TimeTick(DateTime(2024, 1, 5), 3.0),
                TimeTick(DateTime(2024, 1, 6), 4.0),
                TimeTick(DateTime(2024, 1, 7), 5.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(median, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 1.5),
                TimeTick(DateTime(2024, 1, 5), 2.5),
                TimeTick(DateTime(2024, 1, 6), 3.5),
                TimeTick(DateTime(2024, 1, 7), 4.0),
                TimeTick(DateTime(2024, 1, 15), 6.0),
            ]),
        )

        @test isequal(
            ta_rolling(std, ta_for_window, Day(4)),
            TimeArray([
                TimeTick(DateTime(2024, 1, 1), NaN),
                TimeTick(DateTime(2024, 1, 2), 0.7071067811865476),
                TimeTick(DateTime(2024, 1, 5), 0.7071067811865476),
                TimeTick(DateTime(2024, 1, 6), 0.7071067811865476),
                TimeTick(DateTime(2024, 1, 7), 1.0),
                TimeTick(DateTime(2024, 1, 15), NaN),
            ]),
        )
    end

    @testset "Case №3: SMA" begin
        sma_date = TimeArray([
            TimeTick(DateTime(2021, 7), 1.0),
            TimeTick(DateTime(2021, 12), 2.0),
            TimeTick(DateTime(2022, 2), 3.0),
            TimeTick(DateTime(2023, 3), 4.0),
            TimeTick(DateTime(2023, 4), 5.0),
            TimeTick(DateTime(2024, 6), 6.0),
        ])

        @test isequal(
            ta_sma(sma_date, 2),
            TimeArray([
                TimeTick(DateTime(2021, 7), NaN),
                TimeTick(DateTime(2021, 12), 1.5),
                TimeTick(DateTime(2022, 2), 2.5),
                TimeTick(DateTime(2023, 3), 3.5),
                TimeTick(DateTime(2023, 4), 4.5),
                TimeTick(DateTime(2024, 6), 5.5),
            ]),
        )

        @test isequal(
            ta_sma(sma_date, 4),
            TimeArray([
                TimeTick(DateTime(2021, 7), NaN),
                TimeTick(DateTime(2021, 12), NaN),
                TimeTick(DateTime(2022, 2), NaN),
                TimeTick(DateTime(2023, 3), 2.5),
                TimeTick(DateTime(2023, 4), 3.5),
                TimeTick(DateTime(2024, 6), 4.5),
            ]),
        )

        @test isequal(
            ta_sma(sma_date, Month(6)),
            TimeArray([
                TimeTick(DateTime(2021, 7), NaN),
                TimeTick(DateTime(2021, 12), 1.5),
                TimeTick(DateTime(2022, 2), 2.5),
                TimeTick(DateTime(2023, 3), 4.0),
                TimeTick(DateTime(2023, 4), 4.5),
                TimeTick(DateTime(2024, 6), 6.0),
            ]),
        )

        @test isequal(
            ta_sma(sma_date, Year(1)),
            TimeArray([
                TimeTick(DateTime(2021, 7), NaN),
                TimeTick(DateTime(2021, 12), NaN),
                TimeTick(DateTime(2022, 2), 2.0),
                TimeTick(DateTime(2023, 3), 4.0),
                TimeTick(DateTime(2023, 4), 4.5),
                TimeTick(DateTime(2024, 6), 6.0),
            ]),
        )
    end

    @testset "Case №4: Lag" begin
        ta_for_lag = TimeArray([
            TimeTick(DateTime(2024, 1, 1), 1.0),
            TimeTick(DateTime(2024, 1, 2), 2.0),
            TimeTick(DateTime(2024, 1, 3), 3.0),
            TimeTick(DateTime(2024, 1, 4), 4.0),
            TimeTick(DateTime(2024, 1, 5), 5.0),
            TimeTick(DateTime(2024, 1, 6), 6.0),
        ])

        @test isequal(
            ta_lag(ta_for_lag, 3),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 3), NaN),
            TimeTick(DateTime(2024, 1, 4), 1.0),
            TimeTick(DateTime(2024, 1, 5), 2.0),
            TimeTick(DateTime(2024, 1, 6), 3.0),
        ]),
        )

        @test isequal(
            ta_lag(ta_for_lag, 10),
            TimeArray([
            TimeTick(DateTime(2024, 1, 1), NaN),
            TimeTick(DateTime(2024, 1, 2), NaN),
            TimeTick(DateTime(2024, 1, 3), NaN),
            TimeTick(DateTime(2024, 1, 4), NaN),
            TimeTick(DateTime(2024, 1, 5), NaN),
            TimeTick(DateTime(2024, 1, 6), NaN),
        ]),
        )
    end

    @testset "Case №5: WMA" begin
        ta = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), 10),
            (DateTime(2024, 1, 2), 11),
            (DateTime(2024, 1, 3), 12),
            (DateTime(2024, 1, 4), 13),
            (DateTime(2024, 1, 5), 14),
            (DateTime(2024, 1, 6), 15),
            (DateTime(2024, 1, 7), 16),
            (DateTime(2024, 1, 8), 17),
            (DateTime(2024, 1, 9), 18),
            (DateTime(2024, 1, 10), 19),
        ])

        ta_after_wma_3 = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), NaN),
            (DateTime(2024, 1, 2), NaN),
            (DateTime(2024, 1, 3), 11.333333333333332),
            (DateTime(2024, 1, 4), 12.333333333333332),
            (DateTime(2024, 1, 5), 13.333333333333332),
            (DateTime(2024, 1, 6), 14.333333333333332),
            (DateTime(2024, 1, 7), 15.333333333333332),
            (DateTime(2024, 1, 8), 16.333333333333332),
            (DateTime(2024, 1, 9), 17.333333333333332),
            (DateTime(2024, 1, 10), 18.333333333333332),
        ])

        @test isequal(ta_wma(ta, 3), ta_after_wma_3)

        ta_after_wma_7 = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), NaN),
            (DateTime(2024, 1, 2), NaN),
            (DateTime(2024, 1, 3), NaN),
            (DateTime(2024, 1, 4), NaN),
            (DateTime(2024, 1, 5), NaN),
            (DateTime(2024, 1, 6), NaN),
            (DateTime(2024, 1, 7), 13.999999999999998),
            (DateTime(2024, 1, 8), 15.0),
            (DateTime(2024, 1, 9), 16.0),
            (DateTime(2024, 1, 10), 17.0),
        ])

        @test isequal(ta_wma(ta, 7), ta_after_wma_7)
    end

    @testset "Case №5: EMA" begin
        ta = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), 10),
            (DateTime(2024, 1, 2), 11),
            (DateTime(2024, 1, 3), 12),
            (DateTime(2024, 1, 4), 13),
            (DateTime(2024, 1, 5), 14),
            (DateTime(2024, 1, 6), 15),
            (DateTime(2024, 1, 7), 16),
            (DateTime(2024, 1, 8), 17),
            (DateTime(2024, 1, 9), 18),
            (DateTime(2024, 1, 10), 19),
        ])

        ta_after_ema_3 = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), 10.0),
            (DateTime(2024, 1, 2), 10.5),
            (DateTime(2024, 1, 3), 11.25),
            (DateTime(2024, 1, 4), 12.125),
            (DateTime(2024, 1, 5), 13.0625),
            (DateTime(2024, 1, 6), 14.03125),
            (DateTime(2024, 1, 7), 15.015625),
            (DateTime(2024, 1, 8), 16.0078125),
            (DateTime(2024, 1, 9), 17.00390625),
            (DateTime(2024, 1, 10), 18.001953125),
        ])
        
        @test isequal(ta_ema(ta, 3), ta_after_ema_3)

        ta_after_ema_7 = TimeArray{DateTime,Float64}([
            (DateTime(2024, 1, 1), 10.0),
            (DateTime(2024, 1, 2), 10.5),
            (DateTime(2024, 1, 3), 11.0),
            (DateTime(2024, 1, 4), 11.5),
            (DateTime(2024, 1, 5), 12.0),
            (DateTime(2024, 1, 6), 12.5),
            (DateTime(2024, 1, 7), 13.375),
            (DateTime(2024, 1, 8), 14.28125),
            (DateTime(2024, 1, 9), 15.2109375),
            (DateTime(2024, 1, 10), 16.158203125),
        ])
        
        @test isequal(ta_ema(ta, 7), ta_after_ema_7)
    end
end
