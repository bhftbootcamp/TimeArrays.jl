# Custom types

Not only Numbers, but also custom types can be used as time series values.
However, it is worth noting that for the full correct use of custom types as `TimeArrays` values, it is necessary to define some methods, which will be listed below.

## Required methods

To work with the main functions of the package, you need to define the following methods:

| Required methods | Description |
|:-----------------|:------------|
| `Base.isnan(::Type{T})` | Checks whether an object of type `T` is considered `NaN` |
| `TimeArray.ta_nan(::Type{T})` | Returns an object of a custom type `T` that is treated as a `NaN` value. |

## Optional methods

The following methods are useful to define for a custom type:

| Optional methods | Description |
|:-----------------|:------------|
| `Base.isless(x::T, y::T)` | See [`isless`](https://docs.julialang.org/en/v1/base/base/#Base.isless). |
| `Base.isequal(x::T, y::T)` | See [`isequal`](https://docs.julialang.org/en/v1/base/base/#Base.isequal). |
| `Base.:(==)(x::T, y::T)` | See [`==`](https://docs.julialang.org/en/v1/base/math/#Base.:==). |
| `Base.:(+)(x::T, y::T)` | Addition between custom types. |
| `Base.:(-)(x::T, y::T)` | Subtraction between custom types. |
| `Base.:(*)(x::T, y::T)` | Multiplication between custom types. |
| `Base.:(/)(x::T, y::T)` | Division between custom types. |
| `Base.zero(::Type{T})` | Returns an object of a custom type `T` that is treated as a zero value. For example, to use the `sum` method |
| `Base.one(::Type{T})` | Returns an object of a custom type `T` that is treated as a one value. For example, to use the `prod` method |

### Example

Let's look at the necessary method overloads for our custom type that describes a candle:

```julia
struct OHLC
    o::Float64
    h::Float64
    l::Float64
    c::Float64
end
```

Next we will define the necessary methods:

```julia
Base.zero(::Type{OHLC}) = OHLC(0.0, 0.0, 0.0, 0.0)
Base.isnan(x::OHLC) = isnan(x.o) && isnan(x.h) && isnan(x.l) && isnan(x.c)
TimeArrays.ta_nan(::Type{OHLC}) = OHLC(NaN, NaN, NaN, NaN)

Base.isless(x::OHLC, y::OHLC) = isless(x.h, y.h)

function Base.isequal(x::OHLC, y::OHLC)
    return all([
        isequal(x.o, y.o),
        isequal(x.h, y.h),
        isequal(x.l, y.l),
        isequal(x.c, y.c),
    ])
end

function Base.:(==)(x::OHLC, y::OHLC)
    return all([
        x.o == y.o,
        x.h == y.h,
        x.l == y.l,
        x.c == y.c,
    ])
end

Base.:+(left::OHLC, right::OHLC) = OHLC(left.o + right.o, left.h + right.h, left.l + right.l, left.c + right.c)
Base.:-(left::OHLC, right::OHLC) = OHLC(left.o - right.o, left.h - right.h, left.l - right.l, left.c - right.c)
Base.:*(left::OHLC, right::OHLC) = OHLC(left.o * right.o, left.h * right.h, left.l * right.l, left.c * right.c)
Base.:*(left::Number, right::OHLC) = OHLC(left * right.o, left * right.h, left * right.l, left * right.c)
Base.:*(left::OHLC, right::Number) = right * left
Base.:/(left::Number, right::OHLC) = OHLC(left / right.o, left / right.h, left / right.l, left / right.c)
Base.:/(left::OHLC, right::Number) = OHLC(left.o / right, left.h / right, left.l / right, left.c / right)
```

Now we can use `OHLC` as the time series value and use all the available functions:

```julia-repl
julia> t_left = TimeArray([
           TimeTick(DateTime("2024-1-1T1"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-1T2"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-1T3"), OHLC(1, 2, 3, 4)),
       ]);

julia> t_right = TimeArray([
           TimeTick(DateTime("2024-1-1T2"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-1T3"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-1T4"), OHLC(1, 2, 3, 4)),
       ]);

julia> t_left + t_right
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-01T01:00:00, OHLC(NaN, NaN, NaN, NaN))
 TimeTick(2024-01-01T02:00:00, OHLC(2.0, 4.0, 6.0, 8.0))
 TimeTick(2024-01-01T03:00:00, OHLC(2.0, 4.0, 6.0, 8.0))
 TimeTick(2024-01-01T04:00:00, OHLC(2.0, 4.0, 6.0, 8.0))
```

```julia-repl
julia> t_nan = TimeArray([
           TimeTick(DateTime("2024-01-02"), OHLC(1, 1, 1, 1)),
           TimeTick(DateTime("2024-01-03"), OHLC(NaN, NaN, NaN, NaN)),
           TimeTick(DateTime("2024-01-04"), OHLC(NaN, NaN, NaN, NaN)),
           TimeTick(DateTime("2024-01-05"), OHLC(10, 10, 10, 10)),
       ]);

julia> ta_forward_fill(t_nan)
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-02T00:00:00, OHLC(1.0, 1.0, 1.0, 1.0))
 TimeTick(2024-01-03T00:00:00, OHLC(10.0, 10.0, 10.0, 10.0))
 TimeTick(2024-01-04T00:00:00, OHLC(10.0, 10.0, 10.0, 10.0))
 TimeTick(2024-01-05T00:00:00, OHLC(10.0, 10.0, 10.0, 10.0))

julia> ta_backward_fill(t_nan)
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-02T00:00:00, OHLC(1.0, 1.0, 1.0, 1.0))
 TimeTick(2024-01-03T00:00:00, OHLC(1.0, 1.0, 1.0, 1.0))
 TimeTick(2024-01-04T00:00:00, OHLC(1.0, 1.0, 1.0, 1.0))
 TimeTick(2024-01-05T00:00:00, OHLC(10.0, 10.0, 10.0, 10.0))

julia> ta_linear_fill(t_nan)
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-02T00:00:00, OHLC(1.0, 1.0, 1.0, 1.0))
 TimeTick(2024-01-03T00:00:00, OHLC(4.0, 4.0, 4.0, 4.0))
 TimeTick(2024-01-04T00:00:00, OHLC(7.0, 7.0, 7.0, 7.0))
 TimeTick(2024-01-05T00:00:00, OHLC(10.0, 10.0, 10.0, 10.0))
```

```julia-repl
julia> t_ohlc = TimeArray([
           TimeTick(DateTime("2024-1-01"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-02"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-03"), OHLC(1, 2, 3, 4)),
           TimeTick(DateTime("2024-1-04"), OHLC(1, 2, 3, 4)),
       ]);

julia> ta_lag(t_ohlc, 2)
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-01T00:00:00, OHLC(NaN, NaN, NaN, NaN))
 TimeTick(2024-01-02T00:00:00, OHLC(NaN, NaN, NaN, NaN))
 TimeTick(2024-01-03T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))
 TimeTick(2024-01-04T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))

julia> ta_rolling(sum, t_ohlc, 3)
4-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-01T00:00:00, OHLC(NaN, NaN, NaN, NaN))
 TimeTick(2024-01-02T00:00:00, OHLC(NaN, NaN, NaN, NaN))
 TimeTick(2024-01-03T00:00:00, OHLC(3.0, 6.0, 9.0, 12.0))
 TimeTick(2024-01-04T00:00:00, OHLC(3.0, 6.0, 9.0, 12.0))

julia> ta_resample(x -> isempty(x) ? ta_nan(x) : sum(x), t_ohlc, Day(2))
2-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-01T00:00:00, OHLC(2.0, 4.0, 6.0, 8.0))
 TimeTick(2024-01-03T00:00:00, OHLC(2.0, 4.0, 6.0, 8.0))

julia> ta_resample(sum, t_ohlc, Hour(12))
7-element TimeArray{DateTime, OHLC}:
 TimeTick(2024-01-01T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))
 TimeTick(2024-01-01T12:00:00, OHLC(0.0, 0.0, 0.0, 0.0))
 TimeTick(2024-01-02T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))
 TimeTick(2024-01-02T12:00:00, OHLC(0.0, 0.0, 0.0, 0.0))
 TimeTick(2024-01-03T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))
 TimeTick(2024-01-03T12:00:00, OHLC(0.0, 0.0, 0.0, 0.0))
 TimeTick(2024-01-04T00:00:00, OHLC(1.0, 2.0, 3.0, 4.0))
```

## Custom methods

If you are going to use in [`ta_resample`](@ref) or [`ta_rolling`](@ref) some custom reducing function `my_func(...)` that takes a vector of elements of type `V1` and returns a value of another type `V2`, then you will need to define a new method `TimeArrays.return_type` that will return type `V2`:

```julia
function my_func(x::AbstractVector{V1})::V2
    return V2(...)
end

TimeArrays.return_type(::typeof(my_func), ::Type{V1}) = V2
```

This is needed to determine the type of the resulting [`TimeArray`](@ref).

### Example

```julia
using Dates
using TimeArrays

struct Trade
    price::Float64
    volume::Float64
end

function w_avg(p::AbstractVector{Trade})
    return sum(x -> x.price * x.volume, p) / sum(x -> x.volume, p)
end

TimeArrays.return_type(::typeof(w_avg), ::Type{T}) where {T<:Trade} = Float64
```

```julia-repl
julia> t_array = TimeArray([
          TimeTick(DateTime("2024-01-02"), Trade(1.0, 10)),
          TimeTick(DateTime("2024-01-03"), Trade(2.0, 20)),
          TimeTick(DateTime("2024-01-05"), Trade(3.0, 30)),
          TimeTick(DateTime("2024-01-06"), Trade(4.0, 40)),
          TimeTick(DateTime("2024-01-09"), Trade(5.0, 50)),
       ]);

julia> ta_rolling(w_avg, t_array, Day(3))
5-element TimeArray{DateTime, Float64}:
 TimeTick(2024-01-02T00:00:00, NaN)
 TimeTick(2024-01-03T00:00:00, 1.6666666666666667)
 TimeTick(2024-01-05T00:00:00, 2.6)
 TimeTick(2024-01-06T00:00:00, 3.5714285714285716)
 TimeTick(2024-01-09T00:00:00, 5.0)
```
