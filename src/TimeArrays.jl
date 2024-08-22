module TimeArrays

export TimeArray,
    TimeTick,
    ta_timestamp,
    ta_value,
    ta_values

export ta_mergewith,
    ta_merge

export ta_backward_fill,
    ta_forward_fill,
    ta_linear_fill

export ta_rolling,
    ta_sma,
    ta_wma,
    ta_ema,
    ta_lag,
    ta_lead

export ta_resample

export ta_nan

export START_OF_WINDOW,
    END_OF_WINDOW,
    ORIGIN_OF_WINDOW

export CLOSED_LEFT,
    CLOSED_RIGHT

export LABEL_LEFT,
    LABEL_RIGHT

using Dates
using Statistics

"""
    TimeLike <: Union{Dates.TimeType,Real}

`TimeArray`'s timestamp type that accepts `Dates.TimeType` and `Real`.
"""
const TimeLike = Union{Real,TimeType}

"""
    PeriodLike <: Union{Dates.Period,Real}

`TimeArray`'s period type that accepts `Dates.Period` and `Real`.
"""
const PeriodLike = Union{Real,Period}

ta_nan(::AbstractArray{T}) where {T} = ta_nan(T)
ta_nan(::Type{<:Complex}) = Complex(NaN, NaN)
ta_nan(::Type{<:Number})  = NaN
ta_nan(::T) where {T} = ta_nan(T)

promote_nan(::Type{T}) where {T} = promote_type(T, typeof(ta_nan(T)))

function return_type(::Type{F}, types::Type...) where {F<:Function}
    return promote_type(types...)
end

function return_type(f::Function, types::Type...)
    return return_type(typeof(f), types...)
end

function return_type(f::Function, ::Type{AbstractVector{T}}) where {T}
    return return_type(typeof(f), T)
end

include("interface.jl")
include("array.jl")
include("arithmetic.jl")
include("reduce.jl")
include("rolling.jl")
include("resample.jl")
include("sample_data.jl")

end
