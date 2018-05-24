# TODO Import Indicators.jl to get rolling average

module Forecasts

using Base.Iterators: take, cycle
using MultivariateStats: llsq
using ShiftedArrays: lag
using Missings: skipmissing

# package code goes here
export forecast, naivef, snaivef, meanf, rwf, fit!, update!, take, fit, ar

abstract type Forecast end

Base.eltype(::Type{<:Forecast}) = Float64
Base.iteratorsize(::Type{<:Forecast}) = Base.IsInfinite()
Base.done(::Forecast, state) = false

mutable struct NaiveForecast <: Forecast
    value::Float64
end

Base.start(fc::NaiveForecast) = nothing
Base.next(fc::NaiveForecast, state) = (fc.value, nothing)

function naivef(x)
    NaiveForecast(last(x))
end

function forecast(m::NaiveForecast, h::Int)
    repeat([m.value], inner=h)
end

function fit!(m::NaiveForecast, x::AbstractArray{Number})
    m.value = last(x)
end

function update!(m::NaiveForecast, x::Number)
    m.value = last(x)
end

### Seasonal Naive Forecast ###

struct SeasonalNaiveForecast <: Forecast
    # TODO Enforce that length(values) == s
    values::Array{Number,1}
    s::Int  # length of season
end

function snaivef(y, s)
    SeasonalNaiveForecast(y[(end-s+1):end], s)
end

Base.start(fc::SeasonalNaiveForecast) = start(cycle(fc.values))
# TODO Figure out if there's a better way to dispatch this `next`
Base.next(fc::SeasonalNaiveForecast, state) = next(cycle(fc.values), state)

### Mean Forecast ###

mutable struct MeanForecast <: Forecast
    sum::Number
    nobs::Number
end

function meanf(y)
    MeanForecast(sum(y), length(y))
end

Base.start(fc::MeanForecast) = (fc.sum / fc.nobs)
Base.next(fc::MeanForecast, state) = (state, state)

function update!(fc::MeanForecast, y)
    m.sum += sum(y)
    m.mobs += length(y)
end

### RwDriftForecast ###

mutable struct RwDriftForecast <: Forecast
    value::Number
    drift::Number
end

function rwf(y)
    RwDriftForecast(last(y), mean(diff(y)))
end

Base.start(fc::RwDriftForecast) = fc.value
Base.done(fc::RwDriftForecast, state) = false

function Base.next(fc::RwDriftForecast, prev)
    (prev + fc.drift, prev + fc.drift)
end


## AR Model ###
mutable struct ARForecast <: Forecast
    coefs::Array{Float64,2}
end

function ar(y, p=1)
    fit(ARForecast, y, order=p)
end

function fit(::Type{ARForecast}, y::Array{Float64,2}; order=1)
    trunc = x -> x[(order+1):endof(x),:]
    Ly = trunc(lag(y, order))
    Ly = oftype(y, Ly)
    coefs = llsq(Ly, trunc(y))
    ARForecast(coefs)
end

fit(T::Type{ARForecast}, y::Array{Float64,1}; order=1) = fit(T, reshape(y, length(y), 1), order=order)

function forecast(fc::Forecast, h::Int)
    collect(take(fc, h))
end

end # module
