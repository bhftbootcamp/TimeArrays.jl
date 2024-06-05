# arithmetic

"""
    ta_mergewith(f, l_array::TimeArray, r_array::TimeArray; kw...) -> TimeArray

Creates a new TimeArray object by applying a binary function `f` on elements of `left` and `right` TimeArrays.
TimeArrays uses the following rules to establish corresponding elements:
- An element of the first array is matched to the nearest smaller or equal element of the second array.
- If there is no such element in the second array, then the resulting element will be `NaN`.

## Keyword arguments
- `l_merge::Bool = true`: Use `left` timestamps in resulting TimeArray.
- `r_merge::Bool = true`: Use `right` timestamps in resulting TimeArray.
- `padding::Bool = true`: Preserve first timestamps with `NaN` values.

## Examples

```jldoctest
julia> using Dates

julia> t_left = TimeArray([
           TimeTick(DateTime("2024-01-02"), 0.2),
           TimeTick(DateTime("2024-01-05"), 0.5),
       ]);

julia> t_right = TimeArray([
           TimeTick(DateTime("2024-01-01"), 1.0),
           TimeTick(DateTime("2024-01-05"), 5.0),
           TimeTick(DateTime("2024-01-07"), 7.0),
       ]);

julia> ta_mergewith(+, t_left, t_right)
4-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, NaN)
 TimeTick(2024-01-02T00:00:00, 1.2)
 TimeTick(2024-01-05T00:00:00, 5.5)
 TimeTick(2024-01-07T00:00:00, 7.5)

julia> ta_mergewith(-, t_left, t_right; l_merge = false)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-01T00:00:00, NaN)
 TimeTick(2024-01-05T00:00:00, -4.5)
 TimeTick(2024-01-07T00:00:00, -6.5)

julia> ta_mergewith(*, t_left, t_right, r_merge = false, padding = false)
2-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-02T00:00:00, 0.2)
 TimeTick(2024-01-05T00:00:00, 2.5)
```
"""
function ta_mergewith(
    f::Function,
    l_array::TimeArray{T1,V1},
    r_array::TimeArray{T2,V2};
    l_merge::Bool = true,
    r_merge::Bool = true,
    padding::Bool = true,
)::TimeArray where {T1,V1,T2,V2}
    T = promote_type(T1, T2)

    V = if padding && ta_timestamp(l_array[1]) != ta_timestamp(r_array[1])
        promote_nan(return_type(f, V1, V2))
    else
        return_type(f, V1, V2)
    end

    if !l_merge && !r_merge || isempty(l_array) || isempty(r_array)
        return TimeArray{T,V}()
    end

    n_index = 0
    n_length = length(l_array) + length(r_array)
    new_ticks = Vector{TimeTick{T,V}}(undef, n_length)

    l_index, r_index = length(l_array), length(r_array)
    l_timestamp, l_value = l_array[l_index]
    r_timestamp, r_value = r_array[r_index]

    while n_index <= n_length
        n_tick = if l_index < 1 && r_index < 1
            break
        elseif l_index < 1
            if r_merge && padding
                r_timestamp, r_value = r_array[r_index]
                r_index -= 1
                TimeTick{T,V}(r_timestamp, ta_nan(V))
            else
                break
            end
        elseif r_index < 1
            if l_merge && padding
                l_timestamp, l_value = l_array[l_index]
                l_index -= 1
                TimeTick{T,V}(l_timestamp, ta_nan(V))
            else
                break
            end
        else
            r_timestamp, r_value = r_array[r_index]
            l_timestamp, l_value = l_array[l_index]
            n_value = f(l_value, r_value)
            if r_timestamp > l_timestamp
                r_index -= 1
                if r_merge
                    TimeTick{T,V}(r_timestamp, n_value)
                else
                    continue
                end
            elseif l_timestamp > r_timestamp
                l_index -= 1
                if l_merge
                    TimeTick{T,V}(l_timestamp, n_value)
                else
                    continue
                end
            elseif l_timestamp == r_timestamp
                l_index -= 1
                r_index -= 1
                TimeTick{T,V}(l_timestamp, n_value)
            end
        end

        new_ticks[n_index += 1] = n_tick
    end

    return TimeArray{T,V}(reverse!(resize!(new_ticks, n_index)))
end

function Base.:+(l_array::TimeArray, r_array::TimeArray)
    return ta_mergewith(+, l_array, r_array)
end

function Base.:-(l_array::TimeArray, r_array::TimeArray)
    return ta_mergewith(-, l_array, r_array)
end

function Base.:*(l_array::TimeArray, r_array::TimeArray)
    return ta_mergewith(*, l_array, r_array)
end

function Base.:/(l_array::TimeArray, r_array::TimeArray)
    return ta_mergewith(/, l_array, r_array)
end

"""
    ta_merge(f::Function, t_array::TimeArray, value) -> TimeArray
    ta_merge(f::Function, value, t_array::TimeArray) -> TimeArray

Creates a new TimeArray by applying a binary function `f` with `value` on elements of `t_array`.

## Examples
```jldoctest
julia> using Dates

julia> t_array = TimeArray([
           TimeTick(DateTime("2024-01-03"), 2.0),
           TimeTick(DateTime("2024-01-04"), 3.0),
           TimeTick(DateTime("2024-01-08"), 6.0),
       ]);

julia> ta_merge(+, t_array, 2.0)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-03T00:00:00, 4.0)
 TimeTick(2024-01-04T00:00:00, 5.0)
 TimeTick(2024-01-08T00:00:00, 8.0)

julia> ta_merge(/, 18.0, t_array)
3-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-03T00:00:00, 9.0)
 TimeTick(2024-01-04T00:00:00, 6.0)
 TimeTick(2024-01-08T00:00:00, 3.0)
```
"""
function ta_merge end

function ta_merge(f::Function, t_array::TimeArray{T,V1}, value::V2) where {T,V1,V2}
    V3 = promote_type(V1, V2)
    new_ticks = Vector{TimeTick{T,V3}}(undef, length(t_array))
    for i in eachindex(new_ticks)
        new_ticks[i] = TimeTick{T,V3}(ta_timestamp(t_array[i]), f(ta_value(t_array[i]), value))
    end
    return TimeArray{T,V3}(new_ticks, length(new_ticks))
end

function ta_merge(f::Function, value::V2, t_array::TimeArray{T,V1}) where {T,V1,V2}
    return ta_merge((x, y) -> f(y, x), t_array, value)
end

function Base.:+(l_array::TimeArray, r_array::Number)
    return ta_merge(+, l_array, r_array)
end

function Base.:+(l_array::Number, r_array::TimeArray)
    return ta_merge(+, l_array, r_array)
end

function Base.:-(l_array::TimeArray, r_array::Number)
    return ta_merge(-, l_array, r_array)
end

function Base.:-(l_array::Number, r_array::TimeArray)
    return ta_merge(-, l_array, r_array)
end

function Base.:*(l_array::TimeArray, r_array::Number)
    return ta_merge(*, l_array, r_array)
end

function Base.:*(l_array::Number, r_array::TimeArray)
    return ta_merge(*, l_array, r_array)
end

function Base.:/(l_array::TimeArray, r_array::Number)
    return ta_merge(/, l_array, r_array)
end

function Base.:/(l_array::Number, r_array::TimeArray)
    return ta_merge(/, l_array, r_array)
end

function Base.:^(l_array::TimeArray, r_array::Number)
    return ta_merge(^, l_array, r_array)
end

function Base.:-(t_array::TimeArray)
    return -1 * t_array
end
