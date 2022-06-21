# Example Pipeline

## Setup

We first load the module and assign the `UserID` (API token) to a variable.

```@example main
using BEA, DataFrames
const BEA_token = ENV["API_BEA_TOKEN"]
nothing
```

## Datasets

After obtaining the `UserID` for access to the API, one usually starts by looking at what datasets are available.

We can do this using `bea_api_datasets`.

```@example main
datasets = bea_api_datasets(BEA_token)
```

## Parameters for FixedAssets

Let's look at some information for the `FixedAssets` dataset.

We need to lookup which parameters are needed to access that data.

```@example main
parameters = bea_api_parameters(BEA_token, "FixedAssets")
```

The basic information is also available through the documentation for the query struct.

```@example main
@doc FixedAssets
```

It takes a `tablename` and `year`. We can check which `tablename`s are valid using the following method.

## Finding the parameter values

```@example main
faa_tbls = bea_api_parametervalues(
    BEA_token,
    "FixedAssets",
    "tablename")
first(faa_tbls, 6)
```

If we wanted to check whether some value is valid for some parameter conditional on other parameters, we can pass the conditional parameters/values as keyword arguments (examples in the API section).

Say we want to get the investment on software in the private sector (line 78 in the Fixed Assets table 2.7).

```@example main
subset(
    faa_tbls,
    :Description => ByRow(x -> occursin("Table 2.7", x)))
```

We now know the `tablename` for the table of interest.

!!! note
    One difference from the API documentation is that for quarterly not seasonally adjusted the package uses `N` and for quarterly seasonally adjusted it uses `S`.

## Defining a query

```@example main
query = FixedAssets("FAAt207", 2019:2020)
```

## Getting the data

```@example main
faa_tbl27_19_20 = bea_api_data(BEA_token, query)
first(faa_tbl27_19_20, 6)
```

Let us now get the estimates for investment in private software.

```@example main
software = subset(
    faa_tbl27_19_20,
    :LineNumber => ByRow(isequal("78")))
```

```@example main
transform!(
    software,
    [:DataValue, :UNIT_MULT] .=> ByRow(x -> parse(Float64, x)),
    renamecols = false
    )
select(
    software,
    :TimePeriod => ByRow(x -> parse(Int, x)) => :Year,
    :DataValue => identity,
    renamecols = false
    )
```

!!! tip
    When working with quarterly and monthly data, you can use `parse_bea_freq` to parse them into annual, quarterly, or monthly series.
