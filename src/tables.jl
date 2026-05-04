#__ Tables

import Tables

# Make TimeArray a Tables.jl source
Tables.istable(::Type{<:TimeArray}) = true
Tables.rowaccess(::Type{<:TimeArray}) = true
Tables.columnaccess(::Type{<:TimeArray}) = true

# Schema definition - treating timestamp as a column named "timestamp"
function Tables.schema(ta::TimeArray{T,V}) where {T,V}
    return Tables.Schema([:timestamp, :value], [T, V])
end

# Column access interface
Tables.columns(ta::TimeArray) = Tables.CopiedColumns(ta)

function Tables.getcolumn(ta::TimeArray, ::Type{T}, col::Int, nm::Symbol) where {T}
    if col == 1 || nm === :timestamp
        return [ta_timestamp(tick) for tick in ta_values(ta)]
    elseif col == 2 || nm === :value
        return [ta_value(tick) for tick in ta_values(ta)]
    else
        throw(ArgumentError("TimeArray only has :timestamp and :value columns"))
    end
end

function Tables.getcolumn(ta::TimeArray, nm::Symbol)
    if nm === :timestamp
        return [ta_timestamp(tick) for tick in ta_values(ta)]
    elseif nm === :value
        return [ta_value(tick) for tick in ta_values(ta)]
    else
        throw(ArgumentError("TimeArray only has :timestamp and :value columns"))
    end
end

function Tables.getcolumn(ta::TimeArray, i::Int)
    if i == 1
        return [ta_timestamp(tick) for tick in ta_values(ta)]
    elseif i == 2
        return [ta_value(tick) for tick in ta_values(ta)]
    else
        throw(ArgumentError("TimeArray only has :timestamp and :value columns"))
    end
end

Tables.columnnames(ta::TimeArray) = [:timestamp, :value]

# Row access interface
Tables.rows(ta::TimeArray) = TimeArrayRowIterator(ta)

struct TimeArrayRowIterator{T,V}
    ta::TimeArray{T,V}
end

Base.length(iter::TimeArrayRowIterator) = length(iter.ta)
Base.eltype(::TimeArrayRowIterator{T,V}) where {T,V} = TimeArrayRow{T,V}

function Base.iterate(iter::TimeArrayRowIterator, state = 1)
    if state > length(iter.ta)
        return nothing
    end
    tick = iter.ta[state]
    return (TimeArrayRow(ta_timestamp(tick), ta_value(tick)), state + 1)
end

struct TimeArrayRow{T,V} <: Tables.AbstractRow
    timestamp::T
    value::V
end

Tables.getcolumn(row::TimeArrayRow, ::Type, col::Int, nm::Symbol) =
    Tables.getcolumn(row, nm)

function Tables.getcolumn(row::TimeArrayRow, nm::Symbol)
    if nm === :timestamp
        return getfield(row, :timestamp)
    elseif nm === :value
        return getfield(row, :value)
    else
        throw(ArgumentError("TimeArray only has :timestamp and :value columns"))
    end
end

Tables.getcolumn(row::TimeArrayRow, i::Int) = getfield(row, i)

Tables.columnnames(::TimeArrayRow) = [:timestamp, :value]