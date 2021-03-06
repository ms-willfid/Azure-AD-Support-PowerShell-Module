<#
.SYNOPSIS
Make a API request to a protected AAD resource using a Accesss Token.

.DESCRIPTION
Make a API request to a protected AAD resource using a Accesss Token.

.PARAMETER Endpoint
This is the API url you are making a request to.

.PARAMETER AccessToken
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
Invoke-AadProtectedApi -GET -Endpoint "https://graph.microsoft.com/v1.0/me" -AccessToken "eyJ***"

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
       [string]$AccessToken,

       [Parameter(ParameterSetName="GetToken_Get", Mandatory=$True)]
       [string]$Client,

       [Parameter(ParameterSetName="GetToken_Get", Mandatory=$True)]
       [string]$Resource,

       [ValidateSet('GET','PATCH','POST','PUT','DELETE')]
       $Method = "GET",

       [string]
       $Body,

       $ContentType = "application/json"
    ) #end param
    

    # Parameter requirements
    if ( ($Method -eq "POST" -or $Method -eq "PATCH" -or $Method -eq "PUT") -and -not $Body )
    {
        throw "Body required when using POST, PATCH, or PUT"
    }

    if(-not $AccessToken -and -not $Client)
    {
        throw "You must specify either -AccessToken or -Client"
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
        $ClientId = (Get-AadServicePrincipal -Id $Client).AppId
        $ResourceId = (Get-AadServicePrincipal -Id $Resource).AppId
        
        if(!$ClientId) {
            $ClientId = $Client
        }

        if(!$ResourceId) {
            $ResourceId = $Client
        }

        write-verbose "Getting token for $Client and $Resource"
        $token = Get-AadTokenUsingAdal -ClientId $ClientId -ResourceId $ResourceId -UserId $Global:AadSupport.Session.AccountId -Prompt Auto -HideOutput -SkipServicePrincipalSearch
        if($token["Error"]) 
        {
            return $token["Error"]
        }

        $AccessToken = $token.AccessToken
    }

    $Result = @{}
    $Result.Content = @()
    $nextLink = $null

    $RetryAttempts = 0
    $MaxRetryAttempts = 5
    do {
        Show-AadSupportStatusBar

        # Refresh Token if ClientId and ResourceId provided
        if($ClientId -and $ResourceId)
        {
            $token = Get-AadTokenUsingAdal -ClientId $ClientId -ResourceId $ResourceId -UserId $Global:AadSupport.Session.AccountId -Prompt Auto -HideOutput -SkipServicePrincipalSearch
            $AccessToken = $token.AccessToken
        }
        
        #Start-Sleep -Milliseconds 60
        
        if($nextLink)
        {
            $endpoint = $nextLink
            $nextLink = $null
        }

        try {
            write-verbose "Making Graph call..."
            if ($Method -eq "GET")
            {
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $AccessToken" } -Uri $endpoint -Method GET -ContentType $ContentType
            }

            if ($Method -eq "POST" -or $Method -eq "PATCH" -or $Method -eq "PUT")
            {   
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $AccessToken" } -Uri $endpoint -Method $Method -Body $Body -ContentType $ContentType
            }

            if ($Method -eq "DELETE")
            {
                $request = Invoke-WebRequest -Headers @{ "Authorization" = "Bearer $AccessToken" } -Uri $endpoint -Method $Method -ContentType $ContentType
            }

        }
        catch{
            $RetryAttempts++
            Start-Sleep -Milliseconds (1000*$RetryAttempts*2)

            Write-Host "Exception calling API." -ForegroundColor Red
            if($request.Response.Content)
            {
                $String = $request.Response.Content
            }

            elseif($_.Exception.Response) {
                $reqstream = $_.Exception.Response.GetResponseStream()
                $reqstream.Position = 0

                $stream = [System.IO.StreamReader]::new($reqstream)
                $String = $stream.ReadToEnd()
                $stream.Close()
                $reqstream.Close()
            }

            Write-Host $String -ForegroundColor Yellow

            if($_.Exception.Response.StatusCode -eq "429")
            {
                Write-Host "Throttling limit hit: StatusCode 429: Waiting 1 minute. It may take up to 5 minutes" -ForegroundColor Yellow
                Start-Sleep -Seconds 61
                Continue
            }

            elseif($_.Exception.Response.StatusCode -eq "Unauthorized")
            {
                Write-Host "Invalid Access Token." -ForegroundColor Yellow
                throw $_
            }

            elseif($_.Exception.Response.StatusCode -eq "Forbidden")
            {
                Write-Host "Missing Permissions." -ForegroundColor Yellow
                Start-Sleep -Seconds 300
                throw $_
            }
            
            
            if($RetryAttempts -gt $MaxRetryAttempts)
            {
                throw $_
            }
            
            Write-Host ""
            Write-Host "Retrying request!" -ForegroundColor Yellow
            continue
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
            $Result.Content += $request.Content
        }
    } while ($nextLink)
    
    $Result.Headers = $request.Headers
    $Result.StatusCode = $request.StatusCode
    $Result.Response = $request

    if($Result)
    {
        Write-Verbose $request.Headers
        Write-Verbose $request.StatusCode
        Write-Verbose $Result.Response
    }
    

    $ReturnObject = New-Object -TypeName PsCustomObject -Property $Result

    if($ReturnObject.Content)
    {
        $members = $ReturnObject.Content | Get-Member | where {$_.MemberType -eq "NoteProperty"}
        $ValuePropertyExist = $members.Name.Contains("value")
    }

    if(!$ReturnObject.Content.Value -and $ValuePropertyExist)
    {
        return $null
    }

    return $ReturnObject.Content

}


function Test-InvokeAadProtectedApi
{
    Remove-Module AadSupportPreview
    Import-Module AadSupportPreview
    Connect-AadSupport

    # Test 1 returned result from a collection
    $endpoint = "$($Global:AadSupport.Resources.MsGraph)/beta/users?`$filter=userPrincipalName eq 'admin@williamfiddes.onmicrosoft.com'"
    $result = Invoke-AadProtectedApi -Client 'test native app' -Resource 'Microsoft Graph' -Endpoint $Endpoint

    # Test 0 returned results from a collection
    $endpoint = "$($Global:AadSupport.Resources.MsGraph)/beta/users?`$filter=userPrincipalName eq 'admin@williamfiddes.onmicrosot.com'"
    $result = Invoke-AadProtectedApi -Client 'test native app' -Resource 'Microsoft Graph' -Endpoint $Endpoint

    # Test 1 returned result
    $endpoint = "$($Global:AadSupport.Resources.MsGraph)/beta/users/admin@williamfiddes.onmicrosoft.com"
    $result = Invoke-AadProtectedApi -Client 'test native app' -Resource 'Microsoft Graph' -Endpoint $Endpoint

    # Test Pagination
    $endpoint = "$($Global:AadSupport.Resources.MsGraph)/beta/users?`$top=10"
    $result = Invoke-AadProtectedApi -Client 'test native app' -Resource 'Microsoft Graph' -Endpoint $Endpoint
}