"""
    BEA

A client for the U.S. Bureau of Economic Analysis API.
"""
module BEA
    using HTTP: URI, request
    using JSON3: JSON3
    using DataFrames
    using PeriodicalDates: PeriodicalDates, TimeType, MonthlyDate, QuarterlyDate, YearlyDate

    const BEA_API_BASEURL = URI(
        scheme = "https",
        host = "apps.bea.gov",
        path = "/api/data",
        )
    
    foreach(
        file -> include(joinpath(dirname(@__DIR__), "src", "$file.jl")),
        ["datasets", "parameters", "parametervalues", "data"],
        )

    export bea_api_datasets,
        bea_api_parameters,
        bea_api_parametervalues,
        bea_api_data,
        NIPA,
        NIUnderlyingDetail,
        FixedAssets,
        DirectInvestment,
        AMNE,
        GDPbyIndustry,
        ITA,
        IIP,
        InputOutput,
        UnderlyingGDPbyIndustry,
        IntlServTrade,
        Regional
end
