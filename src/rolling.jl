# rolling

"""
    ta_rolling(f::Function, t_array::TimeArray{T,V}, n::Integer) -> TimeArray
    ta_rolling(f::Function, t_array::TimeArray{T,V}, p::Period) -> TimeArray

Applies function `f` in a sliding window of length `n` or period `p` to the elements of `t_array`.
Function `f` must accept a vector with elements of type `V` as input and return a new value, which will be assigned to the corresponding timestamp of each window.

Function signature:
```julia
f(x::AbstractVector{V})::Any = ...
```

If it is impossible to calculate a new value based on the received vector (for example, the vector is empty), then the `NaN` value or an equivalent value (for custom types) must be returned.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-03"), 2.0),
           TimeTick(DateTime("2024-01-04"), 3.0),
           TimeTick(DateTime("2024-01-07"), 4.0),
           TimeTick(DateTime("2024-01-09"), 5.0),
       ]);

julia> ta_rolling(sum, t_array, 3)
5-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, NaN)
 TimeTick(2024-01-03T00:00:00, NaN)
 TimeTick(2024-01-04T00:00:00, 6.0)
 TimeTick(2024-01-07T00:00:00, 9.0)
 TimeTick(2024-01-09T00:00:00, 12.0)

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-03"), 2.0),
           TimeTick(DateTime("2024-01-04"), 3.0),
           TimeTick(DateTime("2024-01-07"), 4.0),
           TimeTick(DateTime("2024-01-09"), 5.0),
       ]);

julia> ta_rolling(sum, t_array, Day(3))
5-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, NaN)
 TimeTick(2024-01-03T00:00:00, 3.0)
 TimeTick(2024-01-04T00:00:00, 5.0)
 TimeTick(2024-01-07T00:00:00, 4.0)
 TimeTick(2024-01-09T00:00:00, 9.0)
```
"""
function ta_rolling end

function ta_rolling(f::Function, t_array::TimeArray{T,V}, window::Integer) where {T,V}
    len = length(t_array)
    V2 = promote_nan(return_type(f, V))
    values = map(ta_value, t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, len)

    for i in 1:min(window - 1, len)
        t = ta_timestamp(t_array[i])
        v = ta_nan(V2)
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    for i in window:len
        t = ta_timestamp(t_array[i])
        v = f(view(values, (i - window + 1):i))
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    return TimeArray{T,V2}(new_ticks, len)
end

function ta_rolling(f::Function, t_array::TimeArray{T,V}, window::Period) where {T,V}
    len = length(t_array)
    V2 = promote_nan(return_type(f, V))
    values = map(ta_value, t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, len)

    l_index = len
    l_timestamp = ta_timestamp(t_array[l_index])

    for r_index in len:-1:1
        r_timestamp = ta_timestamp(t_array[r_index])

        while l_index > 0
            l_timestamp = ta_timestamp(t_array[l_index])
            if l_timestamp > r_timestamp - window
                l_index -= 1
            else
                break
            end
        end

        value = if l_index > 0
            f(view(values, l_index+1:r_index))
        elseif l_index == 0
            l_index = -1
            f(view(values, 1:r_index))
        else
            ta_nan(V2)
        end

        new_ticks[r_index] =TimeTick{T,V2}(r_timestamp, value)
    end

    return TimeArray{T,V2}(new_ticks, len)
end

"""
    ta_sma(t_array::TimeArray, n::Integer) -> TimeArray
    ta_sma(t_array::TimeArray, p::Period) -> TimeArray

Applies [Simple Moving Average](https://en.wikipedia.org/wiki/Moving_average) algorithm of length `n` or period `p` to the elements of `t_array`.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-02"), 1.0),
           TimeTick(DateTime("2024-01-03"), 2.0),
           TimeTick(DateTime("2024-01-05"), 3.0),
           TimeTick(DateTime("2024-01-06"), 4.0),
           TimeTick(DateTime("2024-01-09"), 5.0),
       ]);

julia> ta_sma(t_array, 2)
5-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-02T00:00:00, NaN)
 TimeTick(2024-01-03T00:00:00, 1.5)
 TimeTick(2024-01-05T00:00:00, 2.5)
 TimeTick(2024-01-06T00:00:00, 3.5)
 TimeTick(2024-01-09T00:00:00, 4.5)

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-02"), 1.0),
           TimeTick(DateTime("2024-01-03"), 2.0),
           TimeTick(DateTime("2024-01-05"), 3.0),
           TimeTick(DateTime("2024-01-06"), 4.0),
           TimeTick(DateTime("2024-01-09"), 5.0),
       ]);

julia> ta_sma(t_array, Day(3))
5-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-02T00:00:00, NaN)
 TimeTick(2024-01-03T00:00:00, 1.5)
 TimeTick(2024-01-05T00:00:00, 2.5)
 TimeTick(2024-01-06T00:00:00, 3.5)
 TimeTick(2024-01-09T00:00:00, 5.0)
```
"""
function ta_sma(t_array::TimeArray, window::Union{Integer,Period})
    return ta_rolling(mean, t_array, window)
end

function ta_ema(t_array::TimeArray{T,V}, window::Integer) where {T,V}
    len = length(t_array)
    V2 = promote_nan(V)
    values = map(ta_value, t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, len)

    coef = 2.0 / (window + 1)
    for i in 1:min(window - 1, len)
        t = ta_timestamp(t_array[i])
        v = mean(view(values, 1:i))
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    for i in window:len
        t = ta_timestamp(t_array[i])
        value = ta_value(new_ticks[i - 1])
        v = values[i] = coef * (values[i] - value) + value
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    return TimeArray{T,V2}(new_ticks, len)
end

function ta_wma(t_array::TimeArray{T,V}, window::Integer) where {T,V}
    coef = 1.0 / sum(1:window)
    return ta_rolling(t_array, window) do slice
        length(slice) != window && return ta_nan(V)
        return sum([i * coef * slice[i] for i in 1:window])
    end
end

"""
    ta_lag(t_array::TimeArray, n::Integer) -> TimeArray

Shifts the values of `t_array` elements by `n` positions forward.
Displaced elements that remain without a value are set to `NaN`.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-03-01"), 1.0),
           TimeTick(DateTime("2024-03-02"), 2.0),
           TimeTick(DateTime("2024-03-03"), 3.0),
           TimeTick(DateTime("2024-03-04"), 4.0),
       ]);

julia> ta_lag(t_array, 2)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-03-01T00:00:00, NaN)
 TimeTick(2024-03-02T00:00:00, NaN)
 TimeTick(2024-03-03T00:00:00, 1.0)
 TimeTick(2024-03-04T00:00:00, 2.0)
```
"""
function ta_lag(t_array::TimeArray{T,V}, n::Integer) where {T,V}
    len = length(t_array)
    V2 = promote_nan(V)
    values = map(ta_value, t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, len)

    for i in eachindex(new_ticks)
        t = ta_timestamp(t_array[i])
        v = i <= n ? ta_nan(V2) : values[i - n]
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    return TimeArray(new_ticks)
end

"""
    ta_lead(t_array::TimeArray{T,V}, n::Integer) -> TimeArray

Shifts the values of `t_array` elements by `n` positions backward.
Displaced elements that remain without a value are set to `NaN`.

## Examples

```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-03-01"), 1.0),
           TimeTick(DateTime("2024-03-02"), 2.0),
           TimeTick(DateTime("2024-03-03"), 3.0),
           TimeTick(DateTime("2024-03-04"), 4.0),
       ]);

julia> ta_lead(t_array, 2)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-03-01T00:00:00, 3.0)
 TimeTick(2024-03-02T00:00:00, 4.0)
 TimeTick(2024-03-03T00:00:00, NaN)
 TimeTick(2024-03-04T00:00:00, NaN)
```
"""
function ta_lead(t_array::TimeArray{T,V}, n::Integer) where {T,V}
    len = length(t_array)
    V2 = promote_nan(V)
    values = map(ta_value, t_array)
    new_ticks = Vector{TimeTick{T,V2}}(undef, len)

    for i in eachindex(new_ticks)
        t = ta_timestamp(t_array[i])
        v = i > len - n ? ta_nan(V2) : values[i + n]
        new_ticks[i] = TimeTick{T,V2}(t, v)
    end

    return TimeArray(new_ticks)
end
