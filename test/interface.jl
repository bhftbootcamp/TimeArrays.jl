# interface

@testset verbose = true "TimeTick constructors" begin
    @testset "Case №1: TimeTick from timestamp and value" begin
        @test TimeTick{Int64,Int64}(1.0, 2.0)                           == TimeTick(1, 2)
        @test TimeTick{Float64,Float64}(1, 2)                           == TimeTick(1.0, 2.0)
        @test TimeTick{Date,Float64}(DateTime("2023-01-01"), 2.0)       == TimeTick(Date("2023-01-01"), 2.0)
        @test TimeTick{DateTime,Float64}(Date("2023-01-01"), 2.0)       == TimeTick(DateTime("2023-01-01"), 2.0)
        @test TimeTick{DateTime,Float64}(DateTime("2023-01-01"), 2.0)   == TimeTick(DateTime("2023-01-01"), 2.0)
        @test TimeTick{NanoDate,Float64}(Date("2023-01-01"), 2.0)       == TimeTick(NanoDate("2023-01-01"), 2.0)
        @test TimeTick{Date,Float64}(DateTime("2023-01-01"), 2.0)       == TimeTick(Date("2023-01-01"), 2.0)
        @test TimeTick{Time,Float64}(DateTime("2023-01-01"), 2.0)       == TimeTick(Time("00:00:00"), 2.0)
    end

    @testset "Case №2: TimeTick from Tuple" begin
        @test TimeTick{Int64,Int64}((1.0, 2.0))                         == TimeTick((1, 2))
        @test TimeTick{Float64,Float64}((1, 2))                         == TimeTick((1.0, 2.0))
        @test TimeTick{Date,Float64}((DateTime("2023-01-01"), 2.0))     == TimeTick((Date("2023-01-01"), 2.0))
        @test TimeTick{DateTime,Float64}((Date("2023-01-01"), 2.0))     == TimeTick((DateTime("2023-01-01"), 2.0))
        @test TimeTick{DateTime,Float64}((DateTime("2023-01-01"), 2.0)) == TimeTick((DateTime("2023-01-01"), 2.0))
        @test TimeTick{NanoDate,Float64}((Date("2023-01-01"), 2.0))     == TimeTick((NanoDate("2023-01-01"), 2.0))
        @test TimeTick{Date,Float64}((DateTime("2023-01-01"), 2.0))     == TimeTick((Date("2023-01-01"), 2.0))
        @test TimeTick{Time,Float64}((DateTime("2023-01-01"), 2.0))     == TimeTick((Time("00:00:00"), 2.0))
    end

    @testset "Case №3: TimeTick from Pair" begin
        @test TimeTick{Int64,Int64}(1.0 => 2.0)                         == TimeTick(1 => 2)
        @test TimeTick{Float64,Float64}(1 => 2)                         == TimeTick(1.0 => 2.0)
        @test TimeTick{Date,Float64}(DateTime("2023-01-01") => 2.0)     == TimeTick(Date("2023-01-01") => 2.0)
        @test TimeTick{DateTime,Float64}(Date("2023-01-01") => 2.0)     == TimeTick(DateTime("2023-01-01") => 2.0)
        @test TimeTick{DateTime,Float64}(DateTime("2023-01-01") => 2.0) == TimeTick(DateTime("2023-01-01") => 2.0)
        @test TimeTick{NanoDate,Float64}(Date("2023-01-01") => 2.0)     == TimeTick(NanoDate("2023-01-01") => 2.0)
        @test TimeTick{Date,Float64}(DateTime("2023-01-01") => 2.0)     == TimeTick(Date("2023-01-01") => 2.0)
        @test TimeTick{Time,Float64}(DateTime("2023-01-01") => 2.0)     == TimeTick(Time("00:00:00") => 2.0)
    end

    @testset "Case №4: TimeTick from TimeTick" begin
        @test TimeTick{Float64,Int64}(TimeTick{Int64,Float64}(1.0, 2))                        == TimeTick(1.0, 2)
        @test TimeTick{Date,Int64}(TimeTick{NanoDate,Float64}(DateTime("2023-01-01"), 2))     == TimeTick(Date("2023-01-01"), 2.0)
        @test TimeTick{Time,Int64}(TimeTick{NanoDate,Float64}(DateTime("2023-01-01"), 2))     == TimeTick(Time("00:00:00"), 2.0)
        @test TimeTick{DateTime,Int64}(TimeTick{NanoDate,Float64}(DateTime("2023-01-01"), 2)) == TimeTick(DateTime("2023-01-01"), 2.0)
    end

    @testset "Case №5: TimeTick conversions" begin
        common_tick = TimeTick{DateTime,Float64}(DateTime("2024-01-01T01:02:03"), 1.0)
        @test convert(TimeTick{DateTime,Float64}, common_tick) == common_tick
        @test convert(TimeTick{Date,Int64}, common_tick) == TimeTick{Date,Int64}(Date("2024-01-01"), 1)
        @test convert(Tuple{Date,Int64}, common_tick) == (Date("2024-01-01"), 1)
        @test convert(Tuple, common_tick) == (DateTime("2024-01-01T01:02:03"), 1.0)
        @test convert(Pair{Date,Int64}, common_tick) == (Date("2024-01-01") => 1)
        @test convert(Pair, common_tick) == (DateTime("2024-01-01T01:02:03") => 1.0)

        tuple_tick = (DateTime("2024-01-01T01:02:03"), 1.0)
        @test convert(TimeTick{DateTime,Float64}, tuple_tick) == common_tick
        @test convert(TimeTick{Date,Int64}, tuple_tick) == TimeTick{Date,Int64}(Date("2024-01-01"), 1)
        @test convert(TimeTick, tuple_tick) == TimeTick{DateTime,Float64}(DateTime("2024-01-01T01:02:03"), 1.0)

        pair_tick = DateTime("2024-01-01T01:02:03") => 1.0
        @test convert(TimeTick{DateTime,Float64}, pair_tick) == common_tick
        @test convert(TimeTick{Date,Int64}, pair_tick) == TimeTick{Date,Int64}(Date("2024-01-01"), 1)
        @test convert(TimeTick, pair_tick) == TimeTick{DateTime,Float64}(DateTime("2024-01-01T01:02:03"), 1.0)
    end
end

@testset verbose = true "TimeArrays constructors" begin
    @testset "Case №1: TimeArray from TimeTicks" begin
        date_ticks = [
            TimeTick{Date,Float64}(Date(2021), 1.0),
            TimeTick{Date,Float64}(Date(2022), 2.0),
            TimeTick{Date,Float64}(Date(2023), 3.0),
            TimeTick{Date,Float64}(Date(2024), 4.0),
            TimeTick{Date,Float64}(Date(2025), 5.0),
        ]

        time_ticks = [
            TimeTick{Time,Float64}(Time(1), 1.0),
            TimeTick{Time,Float64}(Time(2), 2.0),
            TimeTick{Time,Float64}(Time(3), 3.0),
            TimeTick{Time,Float64}(Time(4), 4.0),
            TimeTick{Time,Float64}(Time(5), 5.0),
        ]

        value_ticks = [
            TimeTick{Int64,Float64}(1, 1.0),
            TimeTick{Int64,Float64}(2, 2.0),
            TimeTick{Int64,Float64}(3, 3.0),
            TimeTick{Int64,Float64}(4, 4.0),
            TimeTick{Int64,Float64}(5, 5.0),
        ]

        @test TimeArray{Date,Float64}(date_ticks) == TimeArray(date_ticks)
        @test TimeArray{Date,Float64}(date_ticks) == TimeArray(reverse(date_ticks))

        @test TimeArray{Time,Float64}(time_ticks) == TimeArray(time_ticks)
        @test TimeArray{Time,Float64}(time_ticks) == TimeArray(reverse(time_ticks))

        @test TimeArray{Int64,Float64}(value_ticks) == TimeArray(value_ticks)
        @test TimeArray{Int64,Float64}(value_ticks) == TimeArray(reverse(value_ticks))
    end

    @testset "Case №2: TimeArray from Tuples" begin
        date_tuples = [
            (Date(2021), 1.0),
            (Date(2022), 2.0),
            (Date(2023), 3.0),
            (Date(2024), 4.0),
            (Date(2025), 5.0),
        ]

        time_tuples = [
            (Time(1), 1.0),
            (Time(2), 2.0),
            (Time(3), 3.0),
            (Time(4), 4.0),
            (Time(5), 5.0),
        ]

        value_tuples = [
            (1, 1.0),
            (2, 2.0),
            (3, 3.0),
            (4, 4.0),
            (5, 5.0),
        ]

        @test TimeArray{Date,Float64}(date_tuples) == TimeArray(date_tuples)
        @test TimeArray{Date,Float64}(date_tuples) == TimeArray(reverse(date_tuples))

        @test TimeArray{Time,Float64}(time_tuples) == TimeArray(time_tuples)
        @test TimeArray{Time,Float64}(time_tuples) == TimeArray(reverse(time_tuples))

        @test TimeArray{Int64,Float64}(value_tuples) == TimeArray(value_tuples)
        @test TimeArray{Int64,Float64}(value_tuples) == TimeArray(reverse(value_tuples))
    end

    @testset "Case №3: TimeArray from Pairs" begin
        date_pairs = [
            Date(2021) => 1.0,
            Date(2022) => 2.0,
            Date(2023) => 3.0,
            Date(2024) => 4.0,
            Date(2025) => 5.0,
        ]

        time_pairs = [
            Time(1) => 1.0,
            Time(2) => 2.0,
            Time(3) => 3.0,
            Time(4) => 4.0,
            Time(5) => 5.0,
        ]

        value_pairs = [
            1 => 1.0,
            2 => 2.0,
            3 => 3.0,
            4 => 4.0,
            5 => 5.0,
        ]

        @test TimeArray{Date,Float64}(date_pairs) == TimeArray(date_pairs)
        @test TimeArray{Date,Float64}(date_pairs) == TimeArray(reverse(date_pairs))

        @test TimeArray{Time,Float64}(time_pairs) == TimeArray(time_pairs)
        @test TimeArray{Time,Float64}(time_pairs) == TimeArray(reverse(time_pairs))

        @test TimeArray{Int64,Float64}(value_pairs) == TimeArray(value_pairs)
        @test TimeArray{Int64,Float64}(value_pairs) == TimeArray(reverse(value_pairs))
    end

    @testset "Case №3: TimeArray from Anything" begin
        date_anything = [
            TimeTick(Date(2021), 1.0),
            (Date(2022), 2.0),
            Date(2023) => 3.0,
        ]

        time_anything = [
            TimeTick(Time(1), 1.0),
            (Time(2), 2.0),
            Time(3) => 3.0,
        ]

        value_anything = [
            TimeTick(1, 1.0),
            (2, 2.0),
            3 => 3.0,
        ]

        @test TimeArray{Date,Float64}(date_anything) == TimeArray{Date,Float64}(reverse(date_anything))

        @test TimeArray{Time,Float64}(time_anything) == TimeArray{Time,Float64}(reverse(time_anything))

        @test TimeArray{Int64,Float64}(value_anything) == TimeArray{Int64,Float64}(reverse(value_anything))

        @test TimeArray([]) == TimeArray{TimeArrays.TimeLike,Any}([])
        
        @test TimeArray{DateTime,Float64}([]) == TimeArray{DateTime,Float64}([])
    end

    @testset "Case №4: TimeArray from timestamps and values" begin
        date_timestamps = [Date(2021), Date(2022), Date(2023), Date(2024), Date(2025)]
        time_timestamps = [Time(1), Time(2), Time(3), Time(4), Time(5)]
        value_timestamps = [1, 2, 3, 4, 5]

        values = [1.0, 2.0, 3.0, 4.0, 5.0]

        @test TimeArray(date_timestamps, values) == TimeArray(reverse(date_timestamps), reverse(values))

        @test TimeArray(time_timestamps, values) == TimeArray(reverse(time_timestamps), reverse(values))

        @test TimeArray(value_timestamps, values) == TimeArray(reverse(value_timestamps), reverse(values))
    end

    @testset "Case №5: TimeArray from iterator" begin
        struct TimeTickIter
            state::Int
        end
        
        Base.length(x::TimeTickIter) = x.state
        function Base.iterate(x::TimeTickIter, state = 1)
            return state <= x.state ? (TimeTick(state, state), state + 1) : nothing
        end
        
        @test TimeArray(TimeTickIter(5)) == TimeArray([
            TimeTick(1, 1),
            TimeTick(2, 2),
            TimeTick(3, 3),
            TimeTick(4, 4),
            TimeTick(5, 5),
        ])
        
        @test TimeArray{Float64,Float64}(TimeTickIter(5)) == TimeArray([
            TimeTick(1.0, 1.0)
            TimeTick(2.0, 2.0)
            TimeTick(3.0, 3.0)
            TimeTick(4.0, 4.0)
            TimeTick(5.0, 5.0)
        ])
    end
end
