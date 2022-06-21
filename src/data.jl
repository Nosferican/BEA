abstract type BEA_API_Datasets end

function parse_bea_freq(str::AbstractString) :: TimeType
    if occursin(r"^\d{4}M[0-1]\d$", str)
        MonthlyDate(str, "yyyy\\Mmm")
    elseif occursin(r"^\d{4}Q[1-4]$", str)
        QuarterlyDate(str, "yyyy\\Qq")
    elseif occursin(r"^\d{4}$", str)
        YearlyDate(str)
    else
        throw(ArgumentError(str))
    end
end

FREQUENCIES = Dict('N' => "QNSA", 'S' => "QSA")

function preprocess_frequency(f::Char)
    f ∉ ['A', 'Q', 'M', 'S', 'N'] &&
    throw(ArgumentError(
        string(
            "valid frequencies include 'A', 'Q', and 'M' for ",
            "annual, quarterly, and monthly. ",
            "Some datasets use 'S' and 'N' for quarterly seasonally-adjusted or not."))
        )
    string(get(FREQUENCIES, f, f))
end
function preprocess_frequency(f::AbstractVector{Char})
    all(∉(['A', 'Q', 'M', 'S', 'N']), f) &&
        throw(ArgumentError(
            string(
                "valid frequencies include 'A', 'Q', and 'M' for ",
                "annual, quarterly, and monthly. ",
                "Some datasets use 'S' and 'N' for quarterly seasonally-adjusted or not."))
            )
    join(sort!(get.(Ref(FREQUENCIES), f, string.(f))), ',')
end

function preprocess_year(yr::Char)
    yr ≠ 'X' &&
        throw(ArgumentError("Valid years spectification are \"ALL\", 'X', YYYY, or [YYYY, YYYY]..."))
    string(yr)
end
function preprocess_year(yr::AbstractString)
    (yr == "X" || occursin(r"^(?i)all$", yr)) ||
        throw(ArgumentError("Valid years spectification are \"ALL\", 'X', YYYY, or [YYYY, YYYY]..."))
    "ALL"
end
preprocess_year(yr::Integer) = string(yr)
preprocess_year(yr::AbstractVector{<:Integer}) = join(sort(yr), ',')
singleormultiplevals(obj::AbstractString) = obj
singleormultiplevals(obj::Integer) = string(obj)
singleormultiplevals(obj::AbstractVector{<:Union{AbstractString, Integer}}) = join(sort!(string.(obj)), ',')

"""
    NIPA(
        tablename::AbstractString,
        frequency::Union{Frequency, AbstractVector{Frequency}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}}
        ) -> NIPA

This dataset contains data from the National Income and Product Accounts (NIPA) which include measures of the value and composition of U.S.production and the incomes generated in producing it.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = NIPA("T10101", ['A', 'Q'], "ALL")
NIPA("T10101", "A,Q", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = NIPA("T20600", 'M', 2015:2016)
NIPA("T20600", "M", "2015,2016")
```
"""
struct NIPA <: BEA_API_Datasets
    TableName :: String
    Frequency :: String
    Year :: String
    function NIPA(
        tablename::AbstractString,
        frequency::Union{Char, AbstractVector{<:Char}},
        year::Union{AbstractString, Char, Integer, AbstractVector{<:Integer}})

        frequency = preprocess_frequency(frequency)
        year = preprocess_year(year)

        new(tablename, frequency, year)
    end
end

"""
    NIUnderlyingDetail(
        tablename::AbstractString,
        frequency::Union{Frequency, AbstractVector{Frequency}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}}
        ) -> NIUnderlyingDetail

This dataset contains underlying detail data from the National Income and Product Accounts (NIPA) which include measures of the value and composition of U.S.production and the incomes generated in producing it.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = NIUnderlyingDetail("U20305", ['A', 'Q', 'M'], "ALL")
NIUnderlyingDetail("U20305", "A,M,Q", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = NIUnderlyingDetail("U70205S", 'M', 2015:2016)
NIUnderlyingDetail("U70205S", "M", "2015,2016")
```
"""
struct NIUnderlyingDetail <: BEA_API_Datasets
    TableName :: String
    Frequency :: String
    Year :: String
    function NIUnderlyingDetail(
        tablename::AbstractString,
        frequency::Union{Char, AbstractVector{<:Char}},
        year::Union{AbstractString, Char, Integer, AbstractVector{<:Integer}})

        frequency = preprocess_frequency(frequency)
        year = preprocess_year(year)

        new(tablename, frequency, year)
    end
end

"""
    FixedAssets(
        tablename::AbstractString,
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}}
        ) -> FixedAssets

This dataset contains data from the standard set of Fixed Assets tables as published online.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = FixedAssets("FAAt201", "ALL")
FixedAssets("FAAt201", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = FixedAssets("FAAt405", 2015:2016)
FixedAssets("FAAt405", "2015,2016")
```
"""
struct FixedAssets <: BEA_API_Datasets
    TableName :: String
    Year :: String
    function FixedAssets(
        tablename::AbstractString,
        year::Union{AbstractString, Char, Integer, AbstractVector{<:Integer}})
        year = preprocess_year(year)
        new(tablename, year)
    end
end

"""
    DirectInvestment(
        directionofinvestment::AbstractString,
        classification::AbstractString,
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}};
        country::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        industry::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        seriesid::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        getfootnotes::Bool = false
        ) -> DirectInvestment

Direct Investment (DI) — income and financial transactions in direct investment that underlie the U. S. balance of payments statistics, and direct investment positions that underlie the U. S. international investment positions.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = DirectInvestment("Outward", "Country", 2011:2012, country = [650, 699])
DirectInvestment("Outward", "ALL", "Country", "2011,2012", "650,699", "ALL", "No")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = DirectInvestment("Inward", "CountryByIndustry", 2010:2013, country = 308, industry = "3000")
DirectInvestment("Inward", "ALL", "CountryByIndustry", "2010,2011,2012,2013", "308", "3000", "No")
```
"""
struct DirectInvestment <: BEA_API_Datasets
    DirectionOfInvestment :: String
    SeriesID :: String
    Classification :: String
    Year :: String
    Country :: String
    Industry :: String
    GetFootnotes :: String
    function DirectInvestment(
        directionofinvestment::AbstractString,
        classification::AbstractString,
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}};
        country::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        industry::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        seriesid::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        getfootnotes::Bool = false,
        )
        (isa(country, AbstractString) && country ≠ "ALL") &&
            throw(ArgumentError("country has been incorrectly provided."))
        new(
            titlecase(string(directionofinvestment)),
            singleormultiplevals(seriesid),
            classification,
            preprocess_year(year),
            singleormultiplevals(country),
            singleormultiplevals(industry),
            getfootnotes ? "Yes" : "No",
            )
    end
end

"""
    AMNE(
        directionofinvestment::AbstractString,
        allaffiliates::Bool,
        nonbankaffiliatesonly::Bool,
        classification::AbstractString,
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}};
        seriesid::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        country::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        industry::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        state::AbstractString = "ALL",
        getfootnotes::Bool = false
        ) -> AMNE

Activities of Multinational Enterprises (AMNE) — operations and finances of U. S. parent enterprises and their foreign affiliates and U. S. affiliates of foreign MNEs.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = AMNE("Outward", false, false, "CountryByIndustry", 2011:2012, seriesid = 4:5, country = 202)
AMNE("Outward", "0", "0", "4,5", "CountryByIndustry", "2011,2012", "202", "ALL", "ALL", "No")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = AMNE("Inward", false, false, "Country", 2011, seriesid = 8, industry = "0000")
AMNE("Inward", "0", "0", "8", "Country", "2011", "ALL", "0000", "ALL", "No")
```
"""
struct AMNE <: BEA_API_Datasets
    DirectionOfInvestment :: String
    OwnershipLevel :: String
    NonBankAffiliatesOnly :: String
    SeriesID :: String
    Classification :: String
    Year :: String
    Country :: String
    Industry :: String
    State :: String
    GetFootnotes :: String
    function AMNE(
        directionofinvestment::AbstractString,
        allaffiliates::Bool,
        nonbankaffiliatesonly::Bool,
        classification::AbstractString,
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}};
        seriesid::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        country::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        industry::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        state::AbstractString = "ALL",
        getfootnotes::Bool = false,
        )
        new(
            titlecase(string(directionofinvestment)),
            string(convert(Int, allaffiliates)),
            string(convert(Int, nonbankaffiliatesonly)),
            singleormultiplevals(seriesid),
            classification,
            preprocess_year(year),
            singleormultiplevals(country),
            singleormultiplevals(industry),
            state,
            getfootnotes ? "Yes" : "No",
            )
    end
end

"""
    GDPbyIndustry(
        tableid::Union{AbstractString, Integer},
        frequency::Union{Char, AbstractVector{<:Char}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        industry::Union{AbstractString, AbstractVector{<:AbstractString}}
        ) -> GDPbyIndustry

The gross domestic product by industry data are contained within a dataset called GDPbyIndustry. BEA's industry accounts are used extensively by policymakers and businesses to understand industry interactions, productivity trends, and the changing structure of the U. S. economy. The GDP-by-industry dataset includes data in both current and chained (real) dollars. The dataset contains estimates for value added, gross output, intermediate inputs, KLEMS and employment statistics.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = GDPbyIndustry(1, 'A', 2011:2012, "ALL")
GDPbyIndustry("1", "A", "2011,2012", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = GDPbyIndustry(11, ['A', 'Q'], 2010, "11")
GDPbyIndustry("11", "A,Q", "2010", "11")
```
"""
struct GDPbyIndustry <: BEA_API_Datasets
    TableID :: String
    Frequency :: String
    Year :: String
    Industry :: String
    function GDPbyIndustry(
        tableid::Union{AbstractString, Integer},
        frequency::Union{Char, AbstractVector{<:Char}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        industry::Union{AbstractString, AbstractVector{<:AbstractString}},
        )
        tableid = string(tableid)
        frequency = preprocess_frequency(frequency)
        year = preprocess_year(year)
        singleormultiplevals(industry)
        new(tableid, frequency, year, industry)
    end
end

"""
    ITA(
        indicator::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        areaorcountry::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        frequency::Union{Char, AbstractVector{<:Char}} = ['A', 'S', 'N'],
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL"
        ) -> ITA

International Transactions data on U.S. international transactions. BEA's international transactions (balance of payments) accounts include all transactions between U. S. and foreign residents.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = ITA(indicator = "BalGds", areaorcountry = "China", frequency = 'A', year = 2011:2012)
ITA("BalGds", "China", "A", "2011,2012")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = ITA(indicator = "PfInvAssets", areaorcountry = "AllCountries", frequency = 'N', year = 2013)
ITA("PfInvAssets", "AllCountries", "QNSA", "2013")
```
"""
struct ITA <: BEA_API_Datasets
    Indicator :: String
    AreaOrCountry :: String
    Frequency :: String
    Year :: String
    function ITA(;
        indicator::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        areaorcountry::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        frequency::Union{Char, AbstractVector{<:Char}} = ['A', 'S', 'N'],
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        )
        indicator = singleormultiplevals(indicator)
        areaorcountry = singleormultiplevals(areaorcountry)
        frequency = preprocess_frequency(frequency)
        year = preprocess_year(year)
        new(indicator, areaorcountry, frequency, year)
    end
end

"""
    IIP(;
        typeofinvestment::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        component::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        frequency::Union{Char, AbstractVector{<:Char}} = ['A', 'N'],
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL"
        ) -> IPP

This dataset contains data on the U. S. international investment position. BEA's international investment position accounts include the end of period value of accumulated stocks of U. S. financial assets and liabilities.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = IIP(typeofinvestment = "FinAssetsExclFinDeriv", component = "ChgPosPrice", frequency = 'A')
IIP("FinAssetsExclFinDeriv", "ChgPosPrice", "A", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = IIP(typeofinvestment = "FinLiabsFoa", component = "Pos", frequency = 'N', year = 2013)
IIP("FinLiabsFoa", "Pos", "QNSA", "2013")
```
"""
struct IIP <: BEA_API_Datasets
    TypeOfInvestment :: String
    Component :: String
    Frequency :: String
    Year :: String
    function IIP(;
        typeofinvestment::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        component::Union{AbstractVector{<:AbstractString}, AbstractString} = "ALL",
        frequency::Union{Char, AbstractVector{<:Char}} = ['A', 'N'],
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "ALL",
        )
        typeofinvestment = singleormultiplevals(typeofinvestment)
        component = singleormultiplevals(component)
        frequency = preprocess_frequency(frequency)
        year = preprocess_year(year)
        new(typeofinvestment, component, frequency, year)
    end
end

"""
    InputOutput(
        tableid::Union{Integer, AbstractVector{<:Integer}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}}
        ) -> InputOutput

The input-output accounts provide a detailed view of the interrelationships between U.S. producers and users. The Input‐Output dataset contains Make Tables, Use Tables, and Direct and Total Requirements tables.y. The input-output accounts provide a detailed view of the interrelationships between U.S. producers and users. The Input‐Output dataset contains Make Tables, Use Tables, and Direct and Total Requirements tables.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = InputOutput(56, 2010:2013)
InputOutput("56", "2010,2011,2012,2013")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = InputOutput(56:57, 2007)
InputOutput("56,57", "2007")
```
"""
struct InputOutput <: BEA_API_Datasets
    TableID :: String
    Year :: String
    function InputOutput(
        tableid::Union{Integer, AbstractVector{<:Integer}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        )
        tableid = singleormultiplevals(tableid)
        year = preprocess_year(year)
        new(tableid, year)
    end
end

"""
    UnderlyingGDPbyIndustry(
        tableid::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        industry::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        frequency::Union{Char, AbstractVector{<:Char}} = 'A'
        ) -> UnderlyingGDPbyIndustry

The underlying GDP-by-industry dataset includes data in both current and chained (real) dollars. The dataset contains estimates for value added, gross output, and intermediate input statistics. This dataset is structurally similar to the GDPbyIndustry dataset (Appendix F), but contains additional industry detail.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = UnderlyingGDPbyIndustry(210, "ALL", 2010:2013)
UnderlyingGDPbyIndustry("210", "A", "2010,2011,2012,2013", "ALL")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = UnderlyingGDPbyIndustry("ALL", 11, 2012)
UnderlyingGDPbyIndustry("ALL", "A", "2012", "11")
```
"""
struct UnderlyingGDPbyIndustry <: BEA_API_Datasets
    TableID :: String
    Frequency :: String
    Year :: String
    Industry :: String
    function UnderlyingGDPbyIndustry(
        tableid::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        industry::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}},
        frequency::Union{Char, AbstractVector{<:Char}} = 'A'
        )
        tableid = singleormultiplevals(tableid)
        industry = singleormultiplevals(industry)
        year = preprocess_year(year)
        frequency = preprocess_frequency(frequency)
        new(tableid, frequency, year, industry)
    end
end

"""
    IntlServTrade(;
        typeofservice::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        tradedirection::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        affiliation::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        areaorcountry::Union{AbstractString, AbstractVector{<:AbstractString}} = "AllCountries",
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "All"
        ) -> IntlServTrade

This dataset contains annual data on U.S. international trade in services.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = IntlServTrade(typeofservice = "AllTypesOfService", tradedirection = "Imports", areaorcountry = "Germany", year = 2014:2015)
IntlServTrade("AllTypesOfService", "Imports", "ALL", "Germany", "2014,2015")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = IntlServTrade(typeofservice = "Telecom", tradedirection = "Exports", affiliation = "UsParents")
IntlServTrade("Telecom", "Exports", "UsParents", "AllCountries", "ALL")
```
"""
struct IntlServTrade <: BEA_API_Datasets
    TypeOfService :: String
    TradeDirection :: String
    Affiliation :: String
    AreaOrCountry :: String
    Year :: String
    function IntlServTrade(;
        typeofservice::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        tradedirection::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        affiliation::Union{AbstractString, AbstractVector{<:AbstractString}} = "ALL",
        areaorcountry::Union{AbstractString, AbstractVector{<:AbstractString}} = "AllCountries",
        year::Union{AbstractString, Integer, AbstractVector{<:Integer}} = "All",
        )
        typeofservice = singleormultiplevals(typeofservice)
        tradedirection = singleormultiplevals(tradedirection)
        affiliation = singleormultiplevals(affiliation)
        areaorcountry = singleormultiplevals(areaorcountry)
        year = preprocess_year(year)
        new(typeofservice, tradedirection, affiliation, areaorcountry, year)
    end
end

"""
    Regional(
        tablename::AbstractString,
        linecode::Union{AbstractString, Integer},
        geofips::Union{AbstractString, AbstractVector{<:AbstractString}},
        year::Union{AbstractString, Integer, AbstractVector{<:Union{<:AbstractString, Integer}}} = "LAST5"
        ) -> Regional

The Regional dataset contains income and employment estimates from the Regional Economic Accounts by state, county, and metropolitan area

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = Regional("CAINC1", 1, "County", 2012:2013)
Regional("CAINC1", "1", "County", "2012,2013")
```

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = Regional("SAGDP9N", 2, "STATE", "ALL")
Regional("SAGDP9N", "2", "STATE", "ALL")
```
"""
struct Regional <: BEA_API_Datasets
    TableName :: String
    LineCode :: String
    GeoFips :: String
    Year :: String
    function Regional(
        tablename::AbstractString,
        linecode::Union{AbstractString, Integer},
        geofips::Union{AbstractString, AbstractVector{<:AbstractString}},
        year::Union{AbstractString, Integer, AbstractVector{<:Union{<:AbstractString, Integer}}} = "LAST5",
        )
        year = preprocess_year(year)
        new(tablename, string(linecode), geofips, year)
    end
end

datasetname(query::BEA_API_Datasets) = string(typeof(query))
datasetname(query::Union{DirectInvestment, AMNE}) = "MNE"

"""
    bea_api_data(
        BEA_token::AbstractString,
        query::BEA_API_Datasets
        ) -> DataFrame
    
Return data from a query.

# Examples

```jldoctest nipa; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> query = FixedAssets("FAAt201", "ALL")
FixedAssets("FAAt201", "ALL")
```

```jldoctest nipa; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> bea_api_data(BEA_token, query)
9888×10 DataFrame
  Row │ TableName  SeriesCode    LineNumber  LineDescription       TimePeriod  METRIC_NAME      CL_UNIT  UNIT_MULT  Da ⋯
      │ String     String        String      String                String      String           String   String     St ⋯
──────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    1 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1925        Current Dollars  Level    9          22 ⋯
    2 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1926        Current Dollars  Level    9          23
    3 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1927        Current Dollars  Level    9          23
    4 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1928        Current Dollars  Level    9          24
    5 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1929        Current Dollars  Level    9          25 ⋯
    6 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1930        Current Dollars  Level    9          23
    7 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1931        Current Dollars  Level    9          20
    8 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1932        Current Dollars  Level    9          18
    9 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1933        Current Dollars  Level    9          19 ⋯
   10 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1934        Current Dollars  Level    9          19
   11 │ FAAt201    k1ptotl1es00  1           Private fixed assets  1935        Current Dollars  Level    9          19
  ⋮   │     ⋮           ⋮            ⋮                ⋮                ⋮              ⋮            ⋮         ⋮         ⋱
 9879 │ FAAt201    k1ntotl1ae50  103         Other                 2011        Current Dollars  Level    9          27
 9880 │ FAAt201    k1ntotl1ae50  103         Other                 2012        Current Dollars  Level    9          27 ⋯
 9881 │ FAAt201    k1ntotl1ae50  103         Other                 2013        Current Dollars  Level    9          27
 9882 │ FAAt201    k1ntotl1ae50  103         Other                 2014        Current Dollars  Level    9          28
 9883 │ FAAt201    k1ntotl1ae50  103         Other                 2015        Current Dollars  Level    9          28
 9884 │ FAAt201    k1ntotl1ae50  103         Other                 2016        Current Dollars  Level    9          28 ⋯
 9885 │ FAAt201    k1ntotl1ae50  103         Other                 2017        Current Dollars  Level    9          29
 9886 │ FAAt201    k1ntotl1ae50  103         Other                 2018        Current Dollars  Level    9          29
 9887 │ FAAt201    k1ntotl1ae50  103         Other                 2019        Current Dollars  Level    9          30
 9888 │ FAAt201    k1ntotl1ae50  103         Other                 2020        Current Dollars  Level    9          30 ⋯
                                                                                         2 columns and 9867 rows omitted
```

"""
function bea_api_data(BEA_token::AbstractString, query::BEA_API_Datasets) :: DataFrame
    response = BEA.request(
        "GET",
        BEA.URI(
            BEA.BEA_API_BASEURL,
            query = append!(
                [
                    "UserID" => BEA_token,
                    "method" => "GetData",
                    "DatasetName" => BEA.datasetname(query),
                    ],
                ( string(k) => string(getproperty(query, k)) for k in propertynames(query) ),
                )
            ),
        )
    json = BEA.JSON3.read(response.body)
    output = if hasproperty(json.BEAAPI, :Data)
        DataFrame(json.BEAAPI.Data)
    else
        results = json.BEAAPI.Results
        isa(results, AbstractVector) ?
        reduce(vcat, DataFrame(result.Data) for result in results) :
        DataFrame(results.Data)
    end

    # transform!(
    #     output,
    #     :LineNumber => ByRow(x -> parse(Int, x)),
    #     :TimePeriod => ByRow(parse_bea_freq),
    #     :DataValue => ByRow(x -> parse(Float64, replace(x, "," => ""))),
    #     renamecols = false
    #     )
end
