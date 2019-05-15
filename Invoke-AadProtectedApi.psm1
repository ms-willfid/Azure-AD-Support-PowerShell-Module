<#
.SYNOPSIS
Make a API request to a protected AAD resource using a Accesss Token.

.DESCRIPTION
Make a API request to a protected AAD resource using a Accesss Token.

.PARAMETER Endpoint
This is the API url you are making a request to.

.PARAMETER Bearer
Pass the access token to the protected API

.PARAMETER GET
Make a GET request to the protected API

.PARAMETER PATCH
Use the PATCH Http Method

.PARAMETER POST
Use the POST Http Method

.PARAMETER DELETE
Use the DELETE Http Method

.PARAMETER PUT
Use the PUT Http Method

.PARAMETER Body
Include a body content with your API request

.PARAMETER ContentType
Specify a ContentType to use. (Default application/json)

.EXAMPLE
Invoke-AadProtectedApi -GET -Endpoint "https://graph.microsoft.com/v1.0/me" -Bearer "eyJ***"

.NOTES
General notes
#>


function Invoke-AadProtectedApi
{
    [CmdletBinding(DefaultParameterSetName="All")] 
    Param(

       [Parameter(Mandatory=$true)]

       [string]$Endpoint,
       [string]$Bearer,

       [Parameter(ParameterSetName="HttpMethodGet", Mandatory=$True)]
       [switch]
       $GET,

       [Parameter(ParameterSetName="HttpRequestBody", Mandatory=$True)]
       [Parameter(ParameterSetName="HttpMethodPatch", Mandatory=$True)]
       [switch]
       $PATCH,

       [Parameter(ParameterSetName="HttpRequestBody", Mandatory=$True)]
       [Parameter(ParameterSetName="HttpMethodPost", Mandatory=$True)]
       [switch]
       $POST,

       [Parameter(ParameterSetName="HttpRequestBody", Mandatory=$True)]
       [Parameter(ParameterSetName="HttpMethodDelete", Mandatory=$True)]
       [switch]
       $DELETE,

       [Parameter(ParameterSetName="HttpRequestBody", Mandatory=$True)]
       [Parameter(ParameterSetName="HttpMethodPut", Mandatory=$True)]
       [switch]
       $PUT,

       [Parameter(ParameterSetName="HttpRequestBody", Mandatory=$True)]
       [string]
       $Body,


       $ContentType = "application/json"
    ) #end param

    $HttpMethod = "GET"

    if ($POST) { $HttpMethod = "POST" }
    if ($PATCH) { $HttpMethod = "PATCH" }
    if ($PUT) { $HttpMethod = "PUT" }
    if ($DELETE) { $HttpMethod = "DELETE" }


    try {
        if ($HttpMethod -eq "GET")
        {
            return $response = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method GET -ContentType $ContentType
        }

        if ($HttpMethod -eq "POST" -or $HttpMethod -eq "PATCH" -or $HttpMethod -eq "PUT")
        {
            return $response = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method $HttpMethod -Body $Body -ContentType $ContentType
        }

    }
    catch{
        throw $_
    }

}
Export-ModuleMember -Function Invoke-AadProtectedApi