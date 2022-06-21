"""
    bea_api_parameters(
        BEA_token::AbstractString,
        dataset::AbstractString
        ) -> DataFrame

Retrieves a list of the datasets currently offered.

# Examples

```jldoctest; setup = :(using BEA; BEA_token = ENV["API_BEA_TOKEN"]; ENV["COLUMNS"] = 120; ENV["LINES"] = 30;)
julia> bea_api_parameters(BEA_token, "NIPA")
5×7 DataFrame
 Row │ ParameterName  ParameterDescription               ParameterDataType  ParameterIsRequiredFlag  ParameterDefaultV ⋯
     │ String         String                             String             Bool                     String?           ⋯
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ Frequency      A - Annual, Q-Quarterly, M-Month…  string                                true  missing           ⋯
   2 │ ShowMillions   A flag indicating that million-d…  string                               false  N
   3 │ TableID        The standard NIPA table identifi…  integer                              false  missing
   4 │ TableName      The new NIPA table identifier      string                               false  missing
   5 │ Year           List of year(s) of data to retri…  integer                               true  missing           ⋯
                                                                                                       3 columns omitted
```
"""
function bea_api_parameters(BEA_token::AbstractString, DatasetName::AbstractString) :: DataFrame
    response = request(
        "GET",
        URI(
            BEA_API_BASEURL,
            query = [
                "UserID" => BEA_token,
                "method" => "GetParameterList",
                "DatasetName" => DatasetName,
                ]
            )
        )
    json = JSON3.read(response.body)
    result = json.BEAAPI.Results.Parameter
    result = isa(result, AbstractVector) ? result : [result]
    data = DataFrame(
        ParameterName = String[],
        ParameterDescription = String[],
        ParameterDataType = String[],
        ParameterIsRequiredFlag = Bool[],
        ParameterDefaultValue = Union{Missing, String}[],
        MultipleAcceptedFlag = Bool[],
        AllValue = Union{Missing, String}[])
    for param in result
        any(∉(propertynames(data)), keys(param)) && throw(ErrorException("This shouldn't happen"))
        required = param.ParameterIsRequiredFlag == "1"
        push!(
            data,
            (
                ParameterName = param.ParameterName,
                ParameterDescription = param.ParameterDescription,
                ParameterDataType = param.ParameterDataType,
                ParameterIsRequiredFlag = required,
                ParameterDefaultValue = required ? missing : get(param, :ParameterDefaultValue, missing),
                MultipleAcceptedFlag = param.MultipleAcceptedFlag == "1",
                AllValue = get(param, :MultipleAcceptedFlag, missing)
                ),
            )
    end
    data
end
