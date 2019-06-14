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

       [Parameter(ParameterSetName="ProvideToken_Get", Mandatory=$True)]
       [string]$Bearer,

       [Parameter(ParameterSetName="GetToken_Get", Mandatory=$True)]
       [string]$Client,

       [Parameter(ParameterSetName="GetToken_Get", Mandatory=$True)]
       [string]$Resource,

       $Method = "GET",

       [string]
       $Body,

       $ContentType = "application/json"
    ) #end param

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    # Parameter requirements
    if ( ($Method -eq "POST" -or $Method -eq "PATCH" -or $Method -eq "PUT") -and -not $Body )
    {
        throw "Body required when using POST, PATCH, or PUT"
    }

    if(-not $Bearer -and -not $Client)
    {
        throw "You must specify either -Bearer or -Client"
    }


    # Check if Body is file
    if($Body)
    {
        if(Test-Path -Path $Body)
        {
            $content = Get-Content -Path $Body -Raw
            $Body = $content
        }
    }


    if($Client -and $Resource)
    {
        $token = Get-AadTokenUsingAdal -ClientId $Client -ResourceId $Resource -UserId $Global:AadSupport.Session.AccountId -Prompt Auto -HideOutput
        if($token["Error"]) 
        {
            return $token["Error"]
        }

        $bearer = $token.AccessToken
    }

    try {
        if ($Method -eq "GET")
        {
            $response = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method GET -ContentType $ContentType
        }

        if ($Method -eq "POST" -or $Method -eq "PATCH" -or $Method -eq "PUT")
        {   
            $response = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method $Method -Body $Body -ContentType $ContentType
        }

        if ($Method -eq "DELETE")
        {
            $response = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method $Method -ContentType $ContentType
        }

    }
    catch{
        throw $_
    }

    $Result = [ordered]@{}

    try{
        $JsonObject = $response.Content | ConvertFrom-Json
        $Result.Content = $JsonObject
    }
    catch{
        $Result.Content = $response.Content
    }

    
    $Result.Headers = $response.Headers
    $Result.StatusCode = $response.StatusCode
    $Result.Response = $response

    if($Result.Content)
    {
        Write-Host ""
        Write-Host "Response from $Endpoint"
        Write-Host ""
        Write-ObjectToHost $Result.Content
    }

    return $Result

}