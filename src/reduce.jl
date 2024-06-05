# reduce

function Base.reduce(f::Function, t_array::AbstractVector{TimeTick{T,V}}; kw...) where {T,V}
    return reduce(f, map(ta_value, t_array; kw...))
end

function Base.sum(t_array::AbstractVector{TimeTick{T,V}}; init::V = zero(V)) where {T,V}
    return sum(ta_value, t_array; init)
end

function Base.prod(t_array::AbstractVector{TimeTick{T,V}}; init::V = one(V)) where {T,V}
    return prod(ta_value, t_array; init)
end

function Base.any(f::Function, t_array::AbstractVector{TimeTick{T,V}}) where {T,V}
    return any(f, map(ta_value, t_array))
end

function Base.all(f::Function, t_array::AbstractVector{TimeTick{T,V}}) where {T,V}
    return all(f, map(ta_value, t_array))
end

function Base.count(f::Function, t_array::AbstractVector{TimeTick{T,V}}) where {T,V}
    return count(f, map(ta_value, t_array))
end
