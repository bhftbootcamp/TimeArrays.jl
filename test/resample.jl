# resample

@testset verbose = true "Resampling" begin

    @testset "Case №1: Resample empty" begin
        @test ta_resample(sum, TimeArray{DateTime,Float64}(), Day(1)) |> isempty
    end

    @testset "Case №3: Resample custom func" begin
        custom_ta = TimeArray{DateTime,Float64}([
            TimeTick(DateTime("1978-10-15T00:00:00"), 1),
            TimeTick(DateTime("1978-10-15T03:00:00"), 2),
            TimeTick(DateTime("1978-10-15T12:00:00"), 3),
            TimeTick(DateTime("1978-10-16T00:00:00"), 4),
        ])
    
        @test isequal(TimeArray{DateTime,Float64}([
            TimeTick(DateTime("1978-10-15T00:00:00"), 42.0),
            TimeTick(DateTime("1978-10-16T00:00:00"), 42.0),
        ]),
        ta_resample(vec -> 42, custom_ta, Day(1))
        )
    
        @test isequal(TimeArray{DateTime,Float64}([
            TimeTick(DateTime("1978-10-15T00:00:00"), 14),
            TimeTick(DateTime("1978-10-16T00:00:00"), 16),
        ]),
        ta_resample(vec -> sum(vec .^ 2), custom_ta, Day(1)),
        )
    end
    
    @testset "Case №4: Resample custom func with empty" begin
        empty_custom_ta = TimeArray{DateTime,Float64}([
            TimeTick(DateTime("1978-10-15T00:00:00"), 1),
            TimeTick(DateTime("1978-10-16T00:00:00"), 4),
        ])
    
        @test isequal(TimeArray{DateTime,Float64}([
            TimeTick(DateTime("1978-10-15T00:00:00"), 1.0),
            TimeTick(DateTime("1978-10-15T12:00:00"), 0.0),
            TimeTick(DateTime("1978-10-16T00:00:00"), 16.0),
        ]),
        ta_resample(vec -> sum(vec .^ 2), empty_custom_ta, Hour(12))
        )
    end

    @testset "Case №5: Resample Real timestamps" begin
        real_ta = TimeArray{Int64,Float64}([(1, 1), (2, 2), (3, 3)])
    
        @test ta_resample(first, real_ta, 1) == real_ta
        @test ta_resample(first, real_ta, 2) == TimeArray{Int64,Float64}([(0, 1.0), (2, 2.0)])
    end

    @testset "Case №6: Resample Date" begin
        date_ta = TimeArray{Date,Float64}([
            TimeTick(Date("2022-02-01"), 1),
            TimeTick(Date("2022-02-17"), 2),
            TimeTick(Date("2022-03-02"), 3),
        ])

        @test isequal(TimeArray{Date,Float64}([
            TimeTick(Date("2022-01-31"), 1.0),
            TimeTick(Date("2022-02-15"), 2.0),
            TimeTick(Date("2022-03-02"), 3.0),
        ]),
        ta_resample(first, date_ta, Day(15))
        )

        @test isequal(TimeArray{Date,Float64}([
            TimeTick(Date("2022-01-29"), 1.0),
            TimeTick(Date("2022-02-12"), 2.0),
            TimeTick(Date("2022-02-26"), 3.0),
        ]),
        ta_resample(first, date_ta, Week(2))
        )

        @test isequal(TimeArray{Date,Float64}([
            TimeTick(Date("2022-02-01"), 1.0),
            TimeTick(Date("2022-03-01"), 3.0),
        ]),
        ta_resample(first, date_ta, Month(1))
        )
    end
end

@testset verbose = true "Pandas resampling" begin
    test_ta = TimeArray{DateTime,Float64}([
        (DateTime("2024-01-01T00:01:00"), 508),
        (DateTime("2024-01-01T00:29:00"), 925),
        (DateTime("2024-01-01T00:44:00"), 911),
        (DateTime("2024-01-01T01:12:00"), 998),
        (DateTime("2024-01-01T01:17:00"), 93),
        (DateTime("2024-01-01T01:28:00"), 928),
        (DateTime("2024-01-01T01:29:00"), 9),
        (DateTime("2024-01-01T01:31:00"), 587),
        (DateTime("2024-01-01T02:24:00"), 527),
        (DateTime("2024-01-01T03:04:00"), 836),
        (DateTime("2024-01-01T03:16:00"), 469),
        (DateTime("2024-01-01T03:25:00"), 750),
        (DateTime("2024-01-01T03:53:00"), 259),
        (DateTime("2024-01-01T04:14:00"), 843),
        (DateTime("2024-01-01T04:49:00"), 792),
    ])

    @testset "Case №1:{'closed': 'left', 'label': 'left', 'origin': 'start'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_LEFT,
            label = LABEL_LEFT,
            origin = START_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 716.5),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 507.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 685.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 1433.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 2028.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 0.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 2055.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 9.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 9.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 2),
                TimeTick(DateTime("2024-01-01T00:31:00"), 1),
                TimeTick(DateTime("2024-01-01T01:01:00"), 4),
                TimeTick(DateTime("2024-01-01T01:31:00"), 1),
                TimeTick(DateTime("2024-01-01T02:01:00"), 1),
                TimeTick(DateTime("2024-01-01T02:31:00"), 0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 3),
                TimeTick(DateTime("2024-01-01T03:31:00"), 1),
                TimeTick(DateTime("2024-01-01T04:01:00"), 1),
                TimeTick(DateTime("2024-01-01T04:31:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №2:{'closed': 'right', 'label': 'left', 'origin': 'start'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_RIGHT,
            label = LABEL_LEFT,
            origin = START_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 523.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 685.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 2615.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 0.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 2055.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 9.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:01:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:01:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:01:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:31:00"), 1),
                TimeTick(DateTime("2024-01-01T00:01:00"), 1),
                TimeTick(DateTime("2024-01-01T00:31:00"), 1),
                TimeTick(DateTime("2024-01-01T01:01:00"), 5),
                TimeTick(DateTime("2024-01-01T01:31:00"), 0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 1),
                TimeTick(DateTime("2024-01-01T02:31:00"), 0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 3),
                TimeTick(DateTime("2024-01-01T03:31:00"), 1),
                TimeTick(DateTime("2024-01-01T04:01:00"), 1),
                TimeTick(DateTime("2024-01-01T04:31:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №3:{'closed': 'left', 'label': 'right', 'origin': 'start'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_LEFT,
            label = LABEL_RIGHT,
            origin = START_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 716.5),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 507.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 685.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 1433.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 2028.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 0.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 2055.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 998.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 836.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 9.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 469.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 508.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 998.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 836.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 9.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:31:00"), 2),
                TimeTick(DateTime("2024-01-01T01:01:00"), 1),
                TimeTick(DateTime("2024-01-01T01:31:00"), 4),
                TimeTick(DateTime("2024-01-01T02:01:00"), 1),
                TimeTick(DateTime("2024-01-01T02:31:00"), 1),
                TimeTick(DateTime("2024-01-01T03:01:00"), 0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 3),
                TimeTick(DateTime("2024-01-01T04:01:00"), 1),
                TimeTick(DateTime("2024-01-01T04:31:00"), 1),
                TimeTick(DateTime("2024-01-01T05:01:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №4:{'closed': 'right', 'label': 'right', 'origin': 'start'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_RIGHT,
            label = LABEL_RIGHT,
            origin = START_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 523.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 685.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(sum, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 2615.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), 0.0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 2055.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 998.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 836.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 9.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 469.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 998.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 836.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:31:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:01:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:31:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:31:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:01:00"), NaN),
                TimeTick(DateTime("2024-01-01T03:31:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:01:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:31:00"), 843.0),
                TimeTick(DateTime("2024-01-01T05:01:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = START_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:01:00"), 1),
                TimeTick(DateTime("2024-01-01T00:31:00"), 1),
                TimeTick(DateTime("2024-01-01T01:01:00"), 1),
                TimeTick(DateTime("2024-01-01T01:31:00"), 5),
                TimeTick(DateTime("2024-01-01T02:01:00"), 0),
                TimeTick(DateTime("2024-01-01T02:31:00"), 1),
                TimeTick(DateTime("2024-01-01T03:01:00"), 0),
                TimeTick(DateTime("2024-01-01T03:31:00"), 3),
                TimeTick(DateTime("2024-01-01T04:01:00"), 1),
                TimeTick(DateTime("2024-01-01T04:31:00"), 1),
                TimeTick(DateTime("2024-01-01T05:01:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №5:{'closed': 'left', 'label': 'left', 'origin': 'end'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_LEFT,
            label = LABEL_LEFT,
            origin = END_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 918.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 545.5),
                TimeTick(DateTime("2024-01-01T01:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 652.5),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 551.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 1836.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 1091.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 1524.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 1305.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 1102.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 0.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 928.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 911.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 9.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 928.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 911.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 587.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(length, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 1),
                TimeTick(DateTime("2024-01-01T00:19:00"), 2),
                TimeTick(DateTime("2024-01-01T00:49:00"), 2),
                TimeTick(DateTime("2024-01-01T01:19:00"), 3),
                TimeTick(DateTime("2024-01-01T01:49:00"), 0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 1),
                TimeTick(DateTime("2024-01-01T02:49:00"), 2),
                TimeTick(DateTime("2024-01-01T03:19:00"), 1),
                TimeTick(DateTime("2024-01-01T03:49:00"), 2),
                TimeTick(DateTime("2024-01-01T04:19:00"), 0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №6:{'closed': 'right', 'label': 'left', 'origin': 'end'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_RIGHT,
            label = LABEL_LEFT,
            origin = END_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 918.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 545.5),
                TimeTick(DateTime("2024-01-01T01:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 652.5),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 551.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 1836.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 1091.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 1524.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 1305.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 1102.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 928.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 911.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 9.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 925.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 928.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:19:00"), 911.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 587.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:19:00"), 527.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 750.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_LEFT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2023-12-31T23:49:00"), 1),
                TimeTick(DateTime("2024-01-01T00:19:00"), 2),
                TimeTick(DateTime("2024-01-01T00:49:00"), 2),
                TimeTick(DateTime("2024-01-01T01:19:00"), 3),
                TimeTick(DateTime("2024-01-01T01:49:00"), 0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 1),
                TimeTick(DateTime("2024-01-01T02:49:00"), 2),
                TimeTick(DateTime("2024-01-01T03:19:00"), 1),
                TimeTick(DateTime("2024-01-01T03:49:00"), 2),
                TimeTick(DateTime("2024-01-01T04:19:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №7:{'closed': 'left', 'label': 'right', 'origin': 'end'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_LEFT,
            label = LABEL_RIGHT,
            origin = END_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 918.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 545.5),
                TimeTick(DateTime("2024-01-01T01:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 652.5),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 551.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 1836.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 1091.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 1524.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 1305.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 1102.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 0.0),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 928.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 9.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 928.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), NaN),
                TimeTick(DateTime("2024-01-01T05:19:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_LEFT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 1),
                TimeTick(DateTime("2024-01-01T00:49:00"), 2),
                TimeTick(DateTime("2024-01-01T01:19:00"), 2),
                TimeTick(DateTime("2024-01-01T01:49:00"), 3),
                TimeTick(DateTime("2024-01-01T02:19:00"), 0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 1),
                TimeTick(DateTime("2024-01-01T03:19:00"), 2),
                TimeTick(DateTime("2024-01-01T03:49:00"), 1),
                TimeTick(DateTime("2024-01-01T04:19:00"), 2),
                TimeTick(DateTime("2024-01-01T04:49:00"), 0),
                TimeTick(DateTime("2024-01-01T05:19:00"), 1),
            ]),
            sampled,
        )
    end

    @testset "Case №8:{'closed': 'right', 'label': 'right', 'origin': 'end'}" begin
        sampled = ta_resample(
            x -> isempty(x) ? NaN : mean(x),
            test_ta,
            Minute(30),
            closed = CLOSED_RIGHT,
            label = LABEL_RIGHT,
            origin = END_OF_WINDOW,
        )
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 918.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 545.5),
                TimeTick(DateTime("2024-01-01T01:49:00"), 508.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 652.5),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 551.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(sum, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 1836.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 1091.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 1524.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), 0.0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 1305.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 1102.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : maximum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 928.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : minimum(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 9.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(x -> isempty(x) ? NaN : first(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 925.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 998.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 928.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 836.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 259.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled = ta_resample(x -> isempty(x) ? NaN : last(x), test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 508.0),
                TimeTick(DateTime("2024-01-01T00:49:00"), 911.0),
                TimeTick(DateTime("2024-01-01T01:19:00"), 93.0),
                TimeTick(DateTime("2024-01-01T01:49:00"), 587.0),
                TimeTick(DateTime("2024-01-01T02:19:00"), NaN),
                TimeTick(DateTime("2024-01-01T02:49:00"), 527.0),
                TimeTick(DateTime("2024-01-01T03:19:00"), 469.0),
                TimeTick(DateTime("2024-01-01T03:49:00"), 750.0),
                TimeTick(DateTime("2024-01-01T04:19:00"), 843.0),
                TimeTick(DateTime("2024-01-01T04:49:00"), 792.0),
            ]),
            sampled,
        )
        sampled =
            ta_resample(length, test_ta, Minute(30), closed = CLOSED_RIGHT, label = LABEL_RIGHT, origin = END_OF_WINDOW)
        @test isequal(
            TimeArray{DateTime,Float64}([
                TimeTick(DateTime("2024-01-01T00:19:00"), 1),
                TimeTick(DateTime("2024-01-01T00:49:00"), 2),
                TimeTick(DateTime("2024-01-01T01:19:00"), 2),
                TimeTick(DateTime("2024-01-01T01:49:00"), 3),
                TimeTick(DateTime("2024-01-01T02:19:00"), 0),
                TimeTick(DateTime("2024-01-01T02:49:00"), 1),
                TimeTick(DateTime("2024-01-01T03:19:00"), 2),
                TimeTick(DateTime("2024-01-01T03:49:00"), 1),
                TimeTick(DateTime("2024-01-01T04:19:00"), 2),
                TimeTick(DateTime("2024-01-01T04:49:00"), 1),
            ]),
            sampled,
        )
    end
end
