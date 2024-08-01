# array

"""
    replace(t_array::TimeArray, old_new::Pair...; [, count]) -> TimeArray

Return a copy of `t_array` which has all values of `old` replaced by `new` in accordance with `old_new` pair.
If `count` is specified, then replace at most `count` occurrences in total.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ]);

julia> replace(t_array, 1.0 => 10.0, 2.0 => -2.0)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, 10.0)
 TimeTick(2024-01-02T00:00:00, -2.0)
 TimeTick(2024-01-03T00:00:00, 3.0)
```
"""
function Base.replace(t_array::TimeArray, old_new::Pair...; count = length(t_array))
    values = ta_values(t_array)
    timestamps = map(ta_timestamp, values)
    timevalues = map(ta_value, values)
    return TimeArray(timestamps, replace(timevalues, old_new...; count))
end

"""
    replace(f::Function, t_array::TimeArray; [, count]) -> TimeArray

Return a new array where each element is the result of function `f` applied to elements of `t_array`.
If `count` is specified, then replace at most `count` occurrences in total.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ]);

julia> replace(x -> isodd(x) ? -x : x, t_array)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, -1.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-03T00:00:00, -3.0)
```
"""
function Base.replace(f::Function, t_array::TimeArray; count = length(t_array))
    values = ta_values(t_array)
    timestamps = map(ta_timestamp, values)
    timevalues = map(ta_value, values)
    return TimeArray(timestamps, replace(f, timevalues; count))
end

"""
    append!(t_array::TimeArray, items::AbstractVector{TimeTick}) -> TimeArray

Add new values from `items` to `t_array` and sorts them by date in ascending order.

!!! warning
    Avoid inserting data in small batches, as each call to the append method triggers sorting.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ]);

julia> a_values = [
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ];

julia> append!(t_array, a_values)
6-element Vector{TimeTick{DateTime, Float64}}:
 TimeTick(2024-01-01T00:00:00, 1.0)
 TimeTick(2024-01-01T00:00:00, 1.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-03T00:00:00, 3.0)
 TimeTick(2024-01-03T00:00:00, 3.0)
```
"""
function Base.append!(t_array::TimeArray{T,V}, items::AbstractVector{TimeTick{T,V}}) where {T,V}
    values = ta_values(t_array)
    append!(values, items)
    return TimeArray{T,V}(values)
end

"""
    vcat(l_array::TimeArray, r_array::TimeArray) -> TimeArray

Concatenates two `TimeArray` objects vertically.

## Examples

```jldoctest
julia> using Dates

julia> t_array_1 = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ]);

julia> t_array_2 = TimeArray([
           TimeTick(DateTime("2024-01-04"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-01"), 3.0),
       ]);

julia> vcat(t_array_1, t_array_2)
6-element Vector{TimeTick{DateTime, Float64}}:
 TimeTick(2024-01-01T00:00:00, 1.0)
 TimeTick(2024-01-01T00:00:00, 3.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-03T00:00:00, 3.0)
 TimeTick(2024-01-04T00:00:00, 1.0)
```
"""
function Base.vcat(l_array::TimeArray{T1,V1}, r_array::TimeArray{T2,V2}) where {T1,V1,T2,V2}
    values = vcat(ta_values(l_array), ta_values(r_array))
    return TimeArray{promote_type(T1,T2),promote_type(V1,V2)}(values)
end

"""
    cumsum(t_array::TimeArray; kw...) -> TimeArray

Cumulative sum along the TimeTick values.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-03"), 3.0),
       ]);

julia> cumsum(t_array)
6-element Vector{TimeTick{DateTime, Float64}}:
 TimeTick(2024-01-01T00:00:00, 1.0)
 TimeTick(2024-01-02T00:00:00, 3.0)
 TimeTick(2024-01-03T00:00:00, 6.0)
```
"""
function Base.cumsum(t_array::TimeArray{T,V}; kw...) where {T,V}
    values = ta_values(t_array)
    timestamps = map(ta_timestamp, values)
    timevalues = map(ta_value, values)
    return TimeArray(timestamps, cumsum(timevalues; kw...))
end

"""
    ta_backward_fill([, pattern::Function], t_array::TimeArray) -> TimeArray

Return an array where elements that match `pattern` are replaced by nearest previous non-pattern value in `t_array`.
By default `pattern` is `isnan` function.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-03"), 1.0),
           TimeTick(DateTime("2024-01-07"), NaN),
           TimeTick(DateTime("2024-01-09"), NaN),
           TimeTick(DateTime("2024-01-10"), 5.0),
       ]);

julia> ta_backward_fill(t_array)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-03T00:00:00, 1.0)
 TimeTick(2024-01-07T00:00:00, 1.0)
 TimeTick(2024-01-09T00:00:00, 1.0)
 TimeTick(2024-01-10T00:00:00, 5.0)
```
"""
function ta_backward_fill(pattern::Function, t_array::TimeArray{T,V}) where {T,V}
    new_ticks = Vector{TimeTick{T,V}}(undef, length(t_array))
    for i in eachindex(t_array)
        prev = findprev(x -> !pattern(x), t_array, i)
        new_ticks[i] = TimeTick{T,V}(
            ta_timestamp(t_array[i]),
            ta_value(t_array[isnothing(prev) ? i : prev]),
        )
    end
    return TimeArray{T,V}(new_ticks)
end

function ta_backward_fill(t_array::TimeArray)
    return ta_backward_fill(isnan, t_array)
end

"""
    ta_forward_fill([, pattern::Function], t_array::TimeArray) -> TimeArray

Return an array where elements that match `pattern` are replaced by nearest next non-pattern value in `t_array`.
By default `pattern` is `isnan` function.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 2.0),
           TimeTick(DateTime("2024-01-03"), NaN),
           TimeTick(DateTime("2024-01-04"), NaN),
           TimeTick(DateTime("2024-01-08"), 7.0),
       ]);

julia> ta_forward_fill(t_array)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, 2.0)
 TimeTick(2024-01-03T00:00:00, 7.0)
 TimeTick(2024-01-04T00:00:00, 7.0)
 TimeTick(2024-01-08T00:00:00, 7.0)
```
"""
function ta_forward_fill(pattern::Function, t_array::TimeArray{T,V}) where {T,V}
    new_ticks = Vector{TimeTick{T,V}}(undef, length(t_array))
    for i in reverse(eachindex(t_array))
        next = findnext(x -> !pattern(x), t_array, i)
        new_ticks[i] = TimeTick{T,V}(
            ta_timestamp(t_array[i]),
            ta_value(t_array[isnothing(next) ? i : next]),
        )
    end
    return TimeArray{T,V}(new_ticks)
end

function ta_forward_fill(t_array::TimeArray)
    return ta_forward_fill(isnan, t_array)
end

"""
    ta_linear_fill([, pattern::Function], t_array::TimeArray) -> TimeArray

Return an array where elements that match `pattern` are replaced by linear interpolation between nearest not-pattern values in `t_array`.
By default `pattern` is `isnan` function.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-02"), 2.0),
           TimeTick(DateTime("2024-01-04"), NaN),
           TimeTick(DateTime("2024-01-06"), NaN),
           TimeTick(DateTime("2024-01-08"), 8.0),
       ]);

julia> ta_linear_fill(t_array)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-02T00:00:00, 2.0)
 TimeTick(2024-01-04T00:00:00, 4.0)
 TimeTick(2024-01-06T00:00:00, 6.0)
 TimeTick(2024-01-08T00:00:00, 8.0)
```
"""
function ta_linear_fill(pattern::Function, t_array::TimeArray{T,V}) where {T,V}
    new_ticks = Vector{TimeTick{T,V}}(undef, length(t_array))
    for i in eachindex(t_array)
        prev = findprev(x -> !pattern(x), t_array, i)
        next = findnext(x -> !pattern(x), t_array, i)
        new_ticks[i] = if isnothing(prev) || isnothing(next) || prev == next
            t_array[i]
        else
            l_timestamp, l_value = t_array[prev]
            r_timestamp, r_value = t_array[next]
            i_timestamp, i_value = t_array[i]
            k = (i_timestamp - l_timestamp) / (r_timestamp - l_timestamp)
            i_value = l_value + k * (r_value - l_value)
            TimeTick{T,V}(i_timestamp, i_value)
        end
    end
    return TimeArray{T,V}(new_ticks)
end

function ta_linear_fill(t_array::TimeArray)
    return ta_linear_fill(isnan, t_array)
end
