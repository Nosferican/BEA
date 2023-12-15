using BEA, DataFrames
using Test: Test, @testset, @test, @test_throws
using Documenter
API_BEA = ENV["API_BEA_TOKEN"]
# Examples
datasets = bea_api_datasets(API_BEA)

@testset "bea_api_datasets" begin
    @test isa(datasets, DataFrame)
end

parameters = DataFrame()
for dataset in datasets[!,:DatasetName]
    df = bea_api_parameters(API_BEA, dataset)
    df[!,:DatasetName] .= dataset
    append!(parameters, df)
end
select!(parameters, vcat(size(parameters, 2), 1:size(parameters, 2) - 1))

@testset "bea_api_parameters" begin
    @test isa(parameters, DataFrame)
end

@testset "bea_api_parametervalues" begin
    # Find parameters for dataset
    param_for_dataset = bea_api_parametervalues(API_BEA, "Regional", "TableName")
    param_for_dataset = bea_api_parametervalues(API_BEA, "MNE", "Country")
    # Find parameters conditional on others
    param_conditional = bea_api_parametervalues(API_BEA, "Regional", "LineCode", TableName = "SQINC7N", Year = 2020)
    # Not yet implemented
    @test_throws ArgumentError bea_api_parametervalues(API_BEA, "NIPA", "TableName", Year = 2020) 
end

@testset "bea_api_data" begin
    query = DirectInvestment(
        "outward",
        "country",
        2011:2012)
    x = bea_api_data(API_BEA, query)
    @test parse.(Int, sort!(unique(x[!,:Year]))) == 2011:2012
    sleep(0.5)
    query = AMNE(
        "outward",
        false,
        false,
        "CountryByIndustry",
        [2011, 2012],
        seriesid = 4:5,
        country = 202)
    x = bea_api_data(API_BEA, query)
    @test parse.(Int, sort!(unique(x[!,:Year]))) == 2011:2012
    sleep(0.5)
    query = GDPbyIndustry(
        1,
        'A',
        2017:2018,
        "ALL"
        )
    x = bea_api_data(API_BEA, query)
    @test parse.(Int, sort!(unique(x[!,:Year]))) == 2017:2018
    sleep(0.5)
    query = ITA(
        indicator = "BalGds",
        areaorcountry = "China"
        )
    x = bea_api_data(API_BEA, query)
    @test parse(Int, minimum(x[!,:Year])) == 1999
    sleep(0.5)
    query = IIP(
        typeofinvestment = "FinAssetsExclFinDeriv",
        component = "ChgPosPrice"
        )
    x = bea_api_data(API_BEA, query)
    @test parse(Int, minimum(x[!,:Year])) == 2003
    sleep(0.5)
    #= Suspeded while CU finishes
    query = InputOutput(56, 2017:2019)
    x = bea_api_data(API_BEA, query)
    @test parse(Int, minimum(x[!,:Year])) == 2017
    sleep(0.5)
    =#
    query = UnderlyingGDPbyIndustry(
        210,
        "ALL",
        2017:2019
        )
    x = bea_api_data(API_BEA, query)
    @test parse.(Int, sort!(unique(x[!,:Year]))) == 2017:2019
    sleep(0.5)
    query = IntlServTrade()
    x = bea_api_data(API_BEA, query)
    @test parse(Int, minimum(x[!,:Year])) == 1986
    sleep(0.5)
    query = Regional(
        "CAINC1",
        1,
        "County",
        2012:2013
        )
    x = bea_api_data(API_BEA, query)
    @test parse.(Int, sort!(unique(x[!,:TimePeriod]))) == 2012:2013
end

doctest(BEA)
