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

    if(-not $Bearer)
    {
        # REQUIRE AadSupport Session
        RequireConnectAadSupport
        # END REGION
    }
    

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
        write-verbose "Getting token for $Client and $Resource"
        $token = Get-AadTokenUsingAdal -ClientId $Client -ResourceId $Resource -UserId $Global:AadSupport.Session.AccountId -Prompt Auto -HideOutput -SkipServicePrincipalSearch
        if($token["Error"]) 
        {
            return $token["Error"]
        }

        $bearer = $token.AccessToken
    }

    $Result = [ordered]@{}
    $Result.Content = @()
    $nextLink = $null

    do {
        Start-Sleep -Milliseconds 100
        
        if($nextLink)
        {
            $endpoint = $nextLink
            $nextLink = $null
        }

        try {
            write-verbose "Making Graph call..."
            if ($Method -eq "GET")
            {
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method GET -ContentType $ContentType -verbose
            }

            if ($Method -eq "POST" -or $Method -eq "PATCH" -or $Method -eq "PUT")
            {   
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method $Method -Body $Body -ContentType $ContentType -verbose
            }

            if ($Method -eq "DELETE")
            {
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $bearer" } -Uri $endpoint -Method $Method -ContentType $ContentType -verbose
            }

        }
        catch{
            Write-Host "Exception calling API." -ForegroundColor Red
            if($request.Response.Content)
            {
                $request.Response.Content
            }

            elseif($_.Exception.Response) {
                $reqstream = $_.Exception.Response.GetResponseStream()
                $stream = new-object System.IO.StreamReader $reqstream
                $string = $stream.ReadToEnd()
                Write-Host $string
            }
            
            throw $_
        }
    
        try{
            $JsonObject = $request.Content | ConvertFrom-Json
            if($JsonObject.Value)
            {
                $Result.Content += $JsonObject.Value
                if($JsonObject.'@odata.nextLink')
                {
                    $nextLink = $JsonObject.'@odata.nextLink'
                }
                if($JsonObject.'odata.nextLink')
                {
                    if(-not $nextLink -match "https")
                    {
                        $nextLink = $JsonObject.'odata.nextLink'
                        Write-Host "nextLink is not a valid web address."
                        Write-Host $nextLink
                    }
                }
                
            }
            else{
                $Result.Content += $JsonObject
            }
            
        }
        catch{
            $Result.Content = $request.Content
        }
    } while ($nextLink)

    
    $Result.Headers = $request.Headers
    $Result.StatusCode = $request.StatusCode
    $Result.Response = $request

    if($Result.Content)
    {
        Write-Verbose $request.Headers
        Write-Verbose $request.StatusCode
        Write-Verbose $Result.Response
    }

    return $Result.Content

}