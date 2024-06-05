# sample_data

export ta_price_sample_data,
    ta_low_price_sample_data,
    ta_high_price_sample_data

function parse_csv(x::String; types::Dict = Dict{String,Any}())
    rows = split(x, '\n'; keepempty = false)
    names = Tuple(Symbol.(split(rows[begin], ',')))

    return map(rows[2:end]) do x
        vals = split(x, ',')
        outs = []
        for (i, name) in enumerate(names)
            T = get(types, String(name), nothing)
            push!(outs, isnothing(T) ? vals[i] : T(vals[i]))
        end
        NamedTuple{names}(outs)
    end
end

function ta_price_sample_data()
    str = read(joinpath(@__DIR__, "../assets/price_sample_data.csv"), String)
    csv = parse_csv(str, types = Dict("time" => DateTime, "value" => x -> parse(Float64, x)))
    return TimeArray(csv)
end

function ta_high_price_sample_data()
    str = read(joinpath(@__DIR__, "../assets/high_price_sample_data.csv"), String)
    csv = parse_csv(str, types = Dict("time" => DateTime, "value" => x -> parse(Float64, x)))
    return TimeArray(csv)
end

function ta_low_price_sample_data()
    str = read(joinpath(@__DIR__, "../assets/low_price_sample_data.csv"), String)
    csv = parse_csv(str, types = Dict("time" => DateTime, "value" => x -> parse(Float64, x)))
    return TimeArray(csv)
end
