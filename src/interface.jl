# interface

#__ TimeTick

"""
    AbstractTick{T,V}

Supertype for `TimeTick{T,V}` with timestamp of type `T` and value of type `V`.
"""
abstract type AbstractTick{T,V} end

"""
    TimeTick{T,V} <: AbstractTick{T,V}

A type describing a timestamp of type `T<:TimeLike` and its value of type `V`.

## Fields
- `timestamp::T`: The timestamp.
- `value::V`: The value.

## Accessors
- `ta_timestamp(x::TimeTick)` -> `x.timestamp`
- `ta_value(x::TimeTick)` -> `x.value`
"""
struct TimeTick{T<:TimeLike,V<:Any} <: AbstractTick{T,V}
    timestamp::T
    value::V

    function TimeTick{T,V}(timestamp::TimeLike, value) where {T<:TimeLike,V}
        return new{T,V}(timestamp, value)
    end

    function TimeTick{T,V}(x::Tuple{TimeLike,Any}) where {T<:TimeLike,V}
        return new{T,V}(x[1], x[2])
    end

    function TimeTick{T,V}(x::NamedTuple{names,<:Tuple{TimeLike,Any}} where {names}) where {T<:TimeLike,V}
        return new{T,V}(x[1], x[2])
    end

    function TimeTick{T,V}(x::Pair{<:TimeLike,<:Any}) where {T<:TimeLike,V}
        return new{T,V}(x.first, x.second)
    end

    function TimeTick{T,V}(x::TimeTick) where {T<:TimeLike,V}
        return new{T,V}(ta_timestamp(x), ta_value(x))
    end
end

"""
    TimeTick{T,V}(timestamp::TimeLike, value)
    TimeTick(timestamp::T, value::V)

Constructs a [`TimeTick`](@ref) object with the passed `timestamp` and `value`.

## Examples
```jldoctest
julia> using Dates

julia> TimeTick{Date,Float64}(DateTime("2024-01-01T00:00:00"), 100)
TimeTick(2024-01-01, 100.0)

julia> TimeTick(DateTime("2024-01-01T00:00:00"), 100)
TimeTick(2024-01-01T00:00:00, 100)
```
"""
function TimeTick(timestamp::T, value::V) where {T<:TimeLike,V}
    return TimeTick{T,V}(timestamp, value)
end

"""
    TimeTick{T,V}(x::Tuple{TimeLike,Any})
    TimeTick(x::Tuple{T,V})

Constructs a [`TimeTick`](@ref) object from tuple `x` which contains the timestamp and value.

## Examples
```jldoctest
julia> using Dates

julia> TimeTick{Date,Float64}((DateTime("2024-01-01T00:00:00"), 100))
TimeTick(2024-01-01, 100.0)

julia> TimeTick((DateTime("2024-01-01T00:00:00"), 100))
TimeTick(2024-01-01T00:00:00, 100)
```
"""
function TimeTick(x::Tuple{T,V}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x[1], x[2])
end

"""
    TimeTick{T,V}(x::NamedTuple{_,Tuple{TimeLike,Any}})
    TimeTick(x::NamedTuple{_,Tuple{TimeLike,Any}})

Constructs a [`TimeTick`](@ref) object from named tuple `x` which contains the timestamp and value.

## Examples
```jldoctest
julia> using Dates

julia> TimeTick{Date,Float64}((timestamp = DateTime("2024-01-01T00:00:00"), value = 100))
TimeTick(2024-01-01, 100.0)

julia> TimeTick((timestamp = DateTime("2024-01-01T00:00:00"), value = 100))
TimeTick(2024-01-01T00:00:00, 100)
```
"""
function TimeTick(x::NamedTuple{names,Tuple{T,V}}) where {names,T<:TimeLike,V}
    return TimeTick{T,V}(x[1], x[2])
end

"""
    TimeTick{T,V}(x::Pair{TimeLike,Number})
    TimeTick(x::Pair{T,V})

Constructs a [`TimeTick`](@ref) object from pair `x` which contains the timestamp and value.

## Examples
```jldoctest
julia> using Dates

julia> TimeTick{Date,Float64}(DateTime("2024-01-01T00:00:00") => 100)
TimeTick(2024-01-01, 100.0)

julia> TimeTick(DateTime("2024-01-01T00:00:00") => 100)
TimeTick(2024-01-01T00:00:00, 100)
```
"""
function TimeTick(x::Pair{T,V}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x.first, x.second)
end

function Base.show(io::IO, x::TimeTick{T,V}) where {T<:TimeLike,V}
    print(io, "TimeTick(", ta_timestamp(x), ", ", ta_value(x), ")")
end

ta_timestamp(x::TimeTick) = x.timestamp
ta_value(x::TimeTick) = x.value

Base.keytype(::TimeTick{T,V}) where {T,V} = T
Base.valtype(::TimeTick{T,V}) where {T,V} = V
Base.eltype(::Type{TimeTick{T,V}}) where {T,V} = Union{T,V}
Base.isnan(x::TimeTick) = isnan(ta_value(x))
Base.isinf(x::TimeTick) = isinf(ta_value(x))

function Base.convert(::Type{TimeTick{T,V}}, x::TimeTick{T,V}) where {T<:TimeLike,V}
    return x
end

function Base.convert(::Type{TimeTick{T,V}}, x::TimeTick) where {T<:TimeLike,V}
    return TimeTick{T,V}(x)
end

function Base.convert(::Type{TimeTick{T,V}}, x::Tuple{TimeLike,Number}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x)
end

function Base.convert(::Type{TimeTick}, x::Tuple{T,V}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x)
end

function Base.convert(::Type{TimeTick{T,V}}, x::Pair{<:TimeLike,<:Any}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x)
end

function Base.convert(::Type{TimeTick}, x::Pair{T,V}) where {T<:TimeLike,V}
    return TimeTick{T,V}(x)
end

function Base.convert(::Type{Tuple}, x::TimeTick)
    return Tuple(x)
end

function Base.convert(::Type{Tuple{T,V}}, x::TimeTick) where {T<:TimeLike,V}
    return Tuple{T,V}(x)
end

function Base.convert(::Type{Pair}, x::TimeTick)
    return Pair(ta_timestamp(x), ta_value(x))
end

function Base.convert(::Type{Pair{T,V}}, x::TimeTick) where {T<:TimeLike,V}
    return Pair{T,V}(ta_timestamp(x), ta_value(x))
end

function Base.getindex(t::TimeTick, i::Integer)
    i == 1 && return ta_timestamp(t)
    i == 2 && return ta_value(t)
    throw(BoundsError(t, i))
end

Base.firstindex(::TimeTick) = 1
Base.lastindex(::TimeTick) = 2
Base.length(::TimeTick) = 2
Base.isless(l::TimeTick, r::TimeTick) = isless(ta_value(l), ta_value(r))

function Base.iterate(value::TimeTick)
    return (ta_timestamp(value), 2)
end

function Base.iterate(value::TimeTick, index::Integer)
    index == 2 && return (ta_value(value), 3)
    return nothing
end

function Base.:(==)(left::TimeTick, right::TimeTick)::Bool
    return ta_timestamp(left) == ta_timestamp(right) && ta_value(left) == ta_value(right)
end

function Base.isequal(left::TimeTick, right::TimeTick)::Bool
    return isequal(ta_timestamp(left), ta_timestamp(right)) && isequal(ta_value(left), ta_value(right))
end

#__ TimeArray

"""
    AbstractTimeArray{T,V} <: AbstractVector{TimeTick{T,V}}

Supertype for `TimeArray{T,V}` with timestamps of type `T` and values of type `V`.
"""
abstract type AbstractTimeArray{T,V} <: AbstractVector{AbstractTick{T,V}} end

"""
    TimeArray{T,V} <: AbstractTimeArray{T,V}

Type describing a time series with timestamps of type `T` and values of type `V`.

## Fields
- `values::Vector{TimeTick{T,V}}`: Elements of a time series.
- `length::Int64`: The length of the underlying array.

## Accessors
- `ta_values(x::TimeArray)` -> `x.values`
"""
struct TimeArray{T<:TimeLike,V} <: AbstractTimeArray{T,V}
    values::Vector{TimeTick{T,V}}
    length::Int64

    function TimeArray{T,V}(values::AbstractVector{TimeTick{T,V}} = TimeTick{T,V}[]) where {T<:TimeLike,V}
        issorted(values, by = ta_timestamp) || sort!(values, by = ta_timestamp)
        return new{T,V}(values, length(values))
    end

    function TimeArray{T,V}(values::AbstractVector{TimeTick{T,V}}, length::Integer) where {T<:TimeLike,V}
        return new{T,V}(values, length)
    end

    function TimeArray{T,V}(values::AbstractVector) where {T<:TimeLike,V}
        return TimeArray{T,V}(TimeTick{T,V}.(values))
    end
end

"""
    TimeArray{T,V}(values::Vector{TimeTick})
    TimeArray(values::Vector{TimeTick{T,V}})

Creates a `TimeArray{T,V}` object from `values` and sorts them by date in ascending order.

## Examples
```jldoctest
julia> using Dates

julia> values = [
           TimeTick(DateTime("2022-1-1T00:00:00"), 3),
           TimeTick(DateTime("2023-1-1T00:00:00"), 1),
           TimeTick(DateTime("2021-1-1T00:00:00"), 2),
       ];

julia> TimeArray{Date,Float64}(values)
3-element TimeArray{Date, Float64}:
 TimeTick(2021-01-01, 2.0)
 TimeTick(2022-01-01, 3.0)
 TimeTick(2023-01-01, 1.0)

julia> TimeArray(values)
3-element TimeArray{DateTime, Int64}:
 TimeTick(2021-01-01T00:00:00, 2)
 TimeTick(2022-01-01T00:00:00, 3)
 TimeTick(2023-01-01T00:00:00, 1)
```
"""
function TimeArray(values::AbstractVector{TimeTick{T,V}}) where {T<:TimeLike,V}
    return TimeArray{T,V}(values)
end

"""
    TimeArray(values::Vector{Pair{T,V}})
    TimeArray(values::Vector{Tuple{TimeLike,Any}})
    TimeArray(values::Vector{NamedTuple{_,Tuple{T,V}}})
    
Creates a `TimeArray{T,V}` object from `values` and sorts them by date in ascending order.

## Examples
```jldoctest
julia> using Dates

julia> TimeArray([
           DateTime("2024-01-02T00:00:00") => 3,
           DateTime("2024-01-03T00:00:00") => 1,
           DateTime("2024-01-01T00:00:00") => 2,
       ])
3-element TimeArray{DateTime, Int64}:
 TimeTick(2024-01-01T00:00:00, 2)
 TimeTick(2024-01-02T00:00:00, 3)
 TimeTick(2024-01-03T00:00:00, 1)

julia> TimeArray([
           (DateTime("2024-01-02T00:00:00"), 3),
           (DateTime("2024-01-03T00:00:00"), 1),
           (DateTime("2024-01-01T00:00:00"), 2),
       ])
3-element TimeArray{DateTime, Int64}:
 TimeTick(2024-01-01T00:00:00, 2)
 TimeTick(2024-01-02T00:00:00, 3)
 TimeTick(2024-01-03T00:00:00, 1)

julia> TimeArray([
           (time = DateTime("2024-01-02T00:00:00"), value = 3),
           (time = DateTime("2024-01-03T00:00:00"), value = 1),
           (time = DateTime("2024-01-01T00:00:00"), value = 2),
       ])
3-element TimeArray{DateTime, Int64}:
 TimeTick(2024-01-01T00:00:00, 2)
 TimeTick(2024-01-02T00:00:00, 3)
 TimeTick(2024-01-03T00:00:00, 1)
```
"""
function TimeArray(values::AbstractVector{Tuple{T,V}}) where {T<:TimeLike,V}
    return TimeArray{T,V}(values)
end

function TimeArray(values::AbstractVector{NamedTuple{names,Tuple{T,V}}} where {names}) where {T<:TimeLike,V}
    return TimeArray{T,V}(values)
end

function TimeArray(values::AbstractVector{Pair{T,V}}) where {T<:TimeLike,V}
    return TimeArray{T,V}(values)
end

"""
    TimeArray(timestamps::Vector{TimeLike}, values::Vector{Any})

Creates a `TimeArray` by "zipping" together elements of `timestamps` and `values`.

## Examples
```jldoctest
julia> using Dates

julia> timestamps = [
           DateTime("2024-01-02"),
           DateTime("2024-01-03"),
           DateTime("2024-01-01"),
       ];

julia> values = [2.0, 1.0, 3.0];

julia> TimeArray(timestamps, values)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, 3.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-03T00:00:00, 1.0)
```
"""
function TimeArray(timestamp::AbstractVector{T}, values::AbstractVector{V}) where {T<:TimeLike,V}
    return TimeArray{T,V}(TimeTick{T,V}.(timestamp, values))
end

"""
    TimeArray{T,V}(values::AbstractVector)

Creates a `TimeArrays{T,V}` from a `values` that contains any elements that can be passed to [`TimeTick{T,V}`](@ref TimeTick) constructors.

!!! warning
    This approach greatly reduces performance. Use at your own discretion.

## Examples
```jldoctest
julia> using Dates

julia> values = [
           TimeTick(Date("2024-01-02"), 3.0),
           (DateTime("2024-01-03"), 1.0),
           Date("2024-01-01") => 2,
       ];

julia> TimeArray{Date,Int64}(values)
3-element TimeArray{Date, Int64}:
 TimeTick(2024-01-01, 2)
 TimeTick(2024-01-02, 3)
 TimeTick(2024-01-03, 1)
```
"""
function TimeArray(::AbstractVector) end

ta_values(x::TimeArray) = x.values

Base.values(t_array::TimeArray) = ta_values(t_array)
Base.keytype(::TimeArray{T,V}) where {T,V} = T
Base.valtype(::TimeArray{T,V}) where {T,V} = V
Base.eltype(t_array::TimeArray) = eltype(t_array.values)

Base.length(t_array::TimeArray) = t_array.length
Base.isempty(t_array::TimeArray) = length(t_array) == 0 || isempty(ta_values(t_array))
Base.size(t_array::TimeArray) = size(ta_values(t_array))
Base.IndexStyle(::Type{TimeArray}) = Base.IndexLinear()
Base.firstindex(t_array::TimeArray) = 1
Base.lastindex(t_array::TimeArray) = length(t_array)
Base.eachindex(t_array::TimeArray) = Base.oneto(length(t_array))
Base.getindex(t_array::TimeArray, i::Integer) = ta_values(t_array)[i]
Base.getindex(t_array::TimeArray, i::UnitRange{<:Integer}) = TimeArray(ta_values(t_array)[i])
Base.getindex(t_array::TimeArray, i::AbstractVector{<:Integer}) = TimeArray(ta_values(t_array)[i])

function Base.iterate(t_array::TimeArray, index::Integer = 1)
    return index <= length(t_array) ? iterate(ta_values(t_array), index) : nothing
end

function Base.:(==)(left::TimeArray, right::TimeArray)
    return ta_values(left) == ta_values(right)
end

function Base.isequal(left::TimeArray, right::TimeArray)
    return isequal(ta_values(left), ta_values(right))
end
