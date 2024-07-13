"""
    bea_api_datasets(BEA_token::AbstractString) -> DataFrame

Retrieves datasets currently available.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> bea_api_datasets(BEA_token)
13×2 DataFrame
 Row │ DatasetName              DatasetDescription
     │ String                   String
─────┼────────────────────────────────────────────────────────────
   1 │ NIPA                     Standard NIPA tables
   2 │ NIUnderlyingDetail       Standard NI underlying detail ta…
   3 │ MNE                      Multinational Enterprises
   4 │ FixedAssets              Standard Fixed Assets tables
   5 │ ITA                      International Transactions Accou…
   6 │ IIP                      International Investment Position
   7 │ InputOutput              Input-Output Data
   8 │ IntlServTrade            International Services Trade
   9 │ IntlServSTA              International Services Supplied …
  10 │ GDPbyIndustry            GDP by Industry
  11 │ Regional                 Regional data sets
  12 │ UnderlyingGDPbyIndustry  Underlying GDP by Industry
  13 │ APIDatasetMetaData       Metadata about other API datasets

```
"""
function bea_api_datasets(BEA_token::AbstractString) :: DataFrame
    response = request(
        "GET",
        URI(
            BEA_API_BASEURL,
            query = [
                "UserID" => BEA_token,
                "method" => "GetDataSetList",
                ]
            )
        )
    json = JSON3.read(response.body)
    DataFrame(json.BEAAPI.Results.Dataset)
end
