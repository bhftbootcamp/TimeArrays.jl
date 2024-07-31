# resample

#__ TimeGrid

struct TimeGrid{T<:TimeLike,P<:PeriodLike}
    origin::T
    period::P

    function TimeGrid(origin::T, period::P) where {T<:TimeLike,P<:PeriodLike}
        @assert hasmethod(+, (T, P)) "Origin type $T is not compatible with period type $P."
        return new{T,P}(origin, period)
    end
end

function Base.getindex(t_grid::TimeGrid, i::Integer)
    return t_grid.origin + i * t_grid.period
end

function Base.findnext(predicate::Function, t_grid::TimeGrid, i::Integer = 0)
    tᵢ = t_grid[i]
    while !predicate(tᵢ)
        i += 1
        tᵢ = t_grid[i]
    end
    return i
end

function Base.findprev(predicate::Function, t_grid::TimeGrid, i::Integer = 0)
    tᵢ = t_grid[i]
    while !predicate(tᵢ)
        i -= 1
        tᵢ = t_grid[i]
    end
    return i
end

function fit_to_grid(timestamp::TimeLike, t_grid::TimeGrid, closed_left::Bool = true)
    i = if timestamp <= t_grid.origin
        cmp = closed_left ? (<=) : (<)
        findprev(cmp(timestamp), t_grid)
    elseif timestamp > t_grid.origin
        cmp = closed_left ? (>) : (>=)
        findnext(cmp(timestamp), t_grid) - 1
    end
    return (t_grid[i], i)
end

#__ Origin

@enum ORIGIN_TYPE begin
    START_OF_WINDOW
    END_OF_WINDOW
    ORIGIN_OF_WINDOW
end

@inline function fit_origin(t_array::TimeArray{T,V}, ::Val{ORIGIN_OF_WINDOW}) where {T<:Time,V<:Any}
    return typemin(T)
end

@inline function fit_origin(t_array::TimeArray{T,V}, ::Val{ORIGIN_OF_WINDOW}) where {T<:TimeType,V<:Any}
    return trunc(ta_timestamp(t_array[begin]), Year)
end

@inline function fit_origin(t_array::TimeArray{T,V}, ::Val{ORIGIN_OF_WINDOW}) where {T<:Real,V<:Any}
    return zero(T)
end

@inline function fit_origin(t_array::TimeArray{T,V}, ::Val{START_OF_WINDOW}) where {T<:Any,V<:Any}
    return ta_timestamp(t_array[begin])
end

@inline function fit_origin(t_array::TimeArray{T,V}, ::Val{END_OF_WINDOW}) where {T<:Any,V<:Any}
    return ta_timestamp(t_array[end])
end

function fit_time_interval(
    t_array::TimeArray,
    period::PeriodLike,
    origin_type::ORIGIN_TYPE,
    closed_left::Bool = true,
)
    origin = fit_origin(t_array, Val(origin_type))
    t_grid = TimeGrid(origin, period)

    t₀, i₀ = fit_to_grid(ta_timestamp(t_array[begin]), t_grid, closed_left)
    tₙ, iₙ = fit_to_grid(ta_timestamp(t_array[end]), t_grid, closed_left)

    return t₀, tₙ, iₙ - i₀ + 1
end

#__ TimeInterval

struct TimeInterval{T<:TimeLike}
    left::T
    right::T
    closed::T
    label::T

    function TimeInterval(
        l_timestamp::T,
        r_timestamp::T;
        closed_left::Bool = true,
        label_left::Bool = true,
    ) where {T<:TimeLike}
        return new{T}(
            l_timestamp,
            r_timestamp,
            closed_left ? l_timestamp : r_timestamp,
            label_left  ? l_timestamp : r_timestamp,
        )
    end
end

function Base.in(timestamp::T, t_interval::TimeInterval{T}) where {T<:TimeLike}
    return isequal(timestamp, t_interval.closed) ||
           isless(t_interval.left, timestamp)    &&
           isless(timestamp, t_interval.right)
end

#__ IntervalIterator

struct IntervalIterator{T<:TimeLike,P<:PeriodLike}
    t₀::T
    tₙ::T
    Δt::P
    closed_left::Bool
    label_left::Bool

    function IntervalIterator(
        t₀::T,
        tₙ::T,
        Δt::P;
        closed_left::Bool = true,
        label_left::Bool = true,
    ) where {T<:TimeLike,P<:PeriodLike}
        return new{T,P}(t₀, tₙ, Δt, closed_left, label_left)
    end
end

function Base.iterate(iter::IntervalIterator, i::Integer = 0)
    tᵢ = iter.t₀ + i * iter.Δt
    if tᵢ <= iter.tₙ
        return (
            TimeInterval(
                tᵢ,
                tᵢ + iter.Δt;
                closed_left = iter.closed_left,
                label_left = iter.label_left,
            ),
            i + 1,
        )
    else
        return nothing
    end
end

#__ Resampling

@enum CLOSED_SIDE begin
    CLOSED_RIGHT = false
    CLOSED_LEFT = true
end

@enum LABEL_SIDE begin
    LABEL_RIGHT = false
    LABEL_LEFT = true
end

"""
    ta_resample(f::Function, t_array::TimeArray{T,V}, period::PeriodLike; kw...) -> TimeArray

Brings the values of `t_array` to a new time grid with new `period` using the function `f` on intermediate values of the old grid.

Function `f` must accept a vector with elements of type `V` as input and return a new value, which will be assigned to the corresponding timestamp of the each window.
If it is impossible to calculate a new value based on the received vector (for example, the vector is empty), then the `NaN` value or an equivalent value (for custom types) must be returned.

## Keyword arguments
- `origin::ORIGIN_TYPE = ORIGIN_OF_WINDOW`: Start of new grid (Possible values: `ORIGIN_OF_WINDOW`, `START_OF_WINDOW`, `END_OF_WINDOW`).
- `closed::CLOSED_SIDE = CLOSED_LEFT`: Closed side of the half-open subintervals of new grid (Possible values: `CLOSED_LEFT`, `CLOSED_RIGHT`).
- `label::LABEL_SIDE = LABEL_LEFT`: Label side of the subintervals of new grid (Possible values: `LABEL_LEFT`, `LABEL_RIGHT`).

For more information see [`resample section`](@ref resample).

## Examples

```jldoctest
julia> t_array = TimeArray{Int64,Int64}([(i, i) for i in 3:13])
11-element TimeArray{Int64, Int64}:
 TimeTick(3, 3)
 TimeTick(4, 4)
 TimeTick(5, 5)
 TimeTick(6, 6)
 TimeTick(7, 7)
 TimeTick(8, 8)
 TimeTick(9, 9)
 TimeTick(10, 10)
 TimeTick(11, 11)
 TimeTick(12, 12)
 TimeTick(13, 13)

julia> ta_resample(sum, t_array, 4, closed = CLOSED_LEFT, label = LABEL_LEFT)
4-element TimeArray{Int64, Float64}:
 TimeTick(0, 3.0)
 TimeTick(4, 22.0)
 TimeTick(8, 38.0)
 TimeTick(12, 25.0)

julia> ta_resample(sum, t_array, 4, closed = CLOSED_LEFT, label = LABEL_RIGHT)
4-element TimeArray{Int64, Float64}:
 TimeTick(4, 3.0)
 TimeTick(8, 22.0)
 TimeTick(12, 38.0)
 TimeTick(16, 25.0)

julia> ta_resample(sum, t_array, 4, closed = CLOSED_RIGHT, label = LABEL_LEFT)
4-element TimeArray{Int64, Float64}:
 TimeTick(0, 7.0)
 TimeTick(4, 26.0)
 TimeTick(8, 42.0)
 TimeTick(12, 13.0)

julia> ta_resample(sum, t_array, 4, closed = CLOSED_RIGHT, label = LABEL_RIGHT)
4-element TimeArray{Int64, Float64}:
 TimeTick(4, 7.0)
 TimeTick(8, 26.0)
 TimeTick(12, 42.0)
 TimeTick(16, 13.0)
```

```jldoctest
julia> using Dates

julia> t_array = TimeArray{DateTime,Int64}([
           TimeTick(DateTime("2024-01-01"), 1),
           TimeTick(DateTime("2024-01-02"), 2),
           TimeTick(DateTime("2024-01-03"), 3),
           TimeTick(DateTime("2024-01-09"), 4),
           TimeTick(DateTime("2024-01-12"), 5),
           TimeTick(DateTime("2024-01-13"), 6),
           TimeTick(DateTime("2024-01-20"), 7),
       ]);

julia> ta_resample(x -> isempty(x) ? NaN : maximum(x), t_array, Day(3))
7-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, 3.0)
 TimeTick(2024-01-04T00:00:00, NaN)
 TimeTick(2024-01-07T00:00:00, 4.0)
 TimeTick(2024-01-10T00:00:00, 5.0)
 TimeTick(2024-01-13T00:00:00, 6.0)
 TimeTick(2024-01-16T00:00:00, NaN)
 TimeTick(2024-01-19T00:00:00, 7.0)
```
"""
function ta_resample(
    f::Function,
    t_array::TimeArray{T,V},
    period::PeriodLike;
    origin::ORIGIN_TYPE = ORIGIN_OF_WINDOW,
    closed::CLOSED_SIDE = CLOSED_LEFT,
    label::LABEL_SIDE = LABEL_LEFT,
) where {T<:TimeLike,V}
    isempty(t_array) && return t_array
    V2 = promote_nan(return_type(f, V))

    t₀, tₙ, n = fit_time_interval(t_array, period, origin, Bool(closed))
    closed_left = Bool(closed)
    label_left = Bool(label)

    values = ta_value.(t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, n)
    i = 1
    for (j, interval) in enumerate(IntervalIterator(t₀, tₙ, period; closed_left, label_left))
        window_start = i
        while i <= length(t_array) && ta_timestamp(t_array[i]) in interval
            i += 1
        end
        window_end = i - 1
        window = view(values, window_start:window_end)
        sampled_value = f(window)
        new_ticks[j] = TimeTick{T,V2}(interval.label, sampled_value)
    end

    return TimeArray{T,V2}(new_ticks, length(new_ticks))
end
