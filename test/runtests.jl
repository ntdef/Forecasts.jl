using Forecasts
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "NaiveForecast" begin
    data = [1, 2, 3]
    fc = naivef(data)
    resultA = collect(take(fc, 1))
    @test resultA == [3]
    resultB = collect(take(fc, 5))
    @test resultB == [3, 3, 3, 3, 3]
end

@testset "SeasonalNaiveForecast" begin
    data = [1., 2., 3., 4., 1., 2., 3., 4.]
    fc = snaivef(data, 4)
    result = collect(take(fc, 1))
    @test result == [1.]
    result = collect(take(fc, 4))
    @test result == [1., 2., 3., 4.]
end

@testset "MeanForecast" begin
    data = [1., 2., 3., 4., 1., 2., 3., 4.]
    fc = meanf(data)
    result = collect(take(fc, 1))
    @test result == [2.5]
    result = collect(take(fc, 3))
    @test result == [2.5, 2.5, 2.5]
end

@testset "RwDriftForecast" begin
    data = collect(Float64, 1:10)
    fc = rwf(data)
    result = collect(take(fc, 3))
    @test result == [11., 12., 13.]
end

@testset "AR" begin
end


@testset "forecast" begin
    data = collect(Float64, 1:10)
    fc = rwf(data)
    result = forecast(fc, 3)
    @test result == [11., 12., 13.]
end
