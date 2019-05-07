<#
.SYNOPSIS
Get Access Token from token endpoint. Use this when using Resource Owner Password Credential flow or Client Credentials.

.DESCRIPTION
Get Access Token from token endpoint.

.PARAMETER ClientId
Parameter description

.PARAMETER ResourceId
Parameter description

.PARAMETER Scopes
Parameter description

.PARAMETER ClientSecret
Parameter description

.PARAMETER ReplayAddress
Parameter description

.PARAMETER Username
Parameter description

.PARAMETER Password
Parameter description

.PARAMETER Tenant
Parameter description

.PARAMETER Instance
Parameter description

.PARAMETER UseV2
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function Get-AadToken
{
    [CmdletBinding(DefaultParameterSetName="All")] 
    param(
        [Parameter(Mandatory=$true)]
        $ClientId,

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$false)]
        [switch]
        $UseResourceOwner,

        [Parameter(ParameterSetName="UseClientCredential", Mandatory=$false)]
        [switch]
        $UseClientCredential,

        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$false)]
        [switch]
        $UseRefreshToken,   

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$true)]
        $Username = $null,

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$true)]
        $Password = $null,

        [Parameter(ParameterSetName="UseClientCredential", Mandatory=$true)]
        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$false)]
        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$false)]
        $ClientSecret = $null,

        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$true)]
        $RefreshToken,
        
        [Parameter(ParameterSetName="UseClientCredential", Mandatory=$true)]
        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$false)]
        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$false)]
        $Tenant,

        $ResourceId = "https://graph.microsoft.com",
        $Scopes = "openid email profile offline_access https://graph.microsoft.com/.default",
        $ReplyAddress = $null,
        $Instance = "https://login.microsoftonline.com",

        [switch]
        $UseV2 = $false
    )

    $error.Clear()
    $scriptError = $null
    
    # Set Grant_Type
    if (-not $UseResourceOwner -and -not $UseClientCredential -and -not $UseRefreshToken)
    {
        do {
            $isValidChoice = $true
            Write-Host ""
            Write-Host "Do you want to..." -ForegroundColor Yellow
            Write-Host "1: Resource Owner (Provice user name and password)"
            Write-Host "2: Client Credential (Provice Client ID and Client Secret)"
            Write-Host "3: Refresh (Provide Refresh Token)"
            Write-Host "Type 'exit' to quit."
            Write-Host ""
            $choice = Read-Host -Prompt "Enter your choice (#)"
            Write-Host ""
            switch ($choice) 
            {
                "1" 
                {
                    $UseResourceOwner = $true 
                    break
                }

                "2" 
                {
                    $UseClientCredential = $true 
                    break
                }

                "3" 
                {
                    $UseRefreshToken = $true
                    break
                }

                "exit" {return}

                "default" 
                {
                    $isValidChoice = $false; 
                    break
                }
            }
        } while (-not $isValidChoice)
    }

    if ($UseResourceOwner)
    {
        $GrantType = "password"
    }

    if ($UseClientCredential)
    {
        
    }

    if ($UseRefreshToken)
    {
        $GrantType = "refresh_token"
    }


    # Requirements for ClientCredentials
    if($UseClientCredential)
    {
        $GrantType = "client_credentials"

        if (-not $Tenant)
        {
            $Tenant = Read-Host -Prompt "Tenant"
        }

        if (-not $ClientSecret)
        {
            $ClientSecret = Read-Host -Prompt "ClientSecret"
        }
    }


    # Requirements for Resource Owner
    if($UseResourceOwner)
    {
        $GrantType = "password"
        
        if (-not $Username)
        {
            $Username = Read-Host -Prompt "Username"
        }

        if (-not $Password)
        {
            $Password = Read-Host -AsSecureString -Prompt "Password"
        }
    }


    # Requirements for Refresh Token
    if($UseRefreshToken)
    {
        $GrantType = "refresh_token"
        if (-not $RefreshToken)
        {
            $RefreshToken = Read-Host -Prompt "Refresh Token"
        }
    }


    # Set default Tenant
    if (-not $Tenant)
    {
        $Tenant = "common"
    }


    # Start initializing the Token result object
    $token = @{}

    # Start initializing the token endpoint POST content
    $body            = @{}

    # Set up if AAD V1 or V2 authentication is used...
    if ($UseV2) {
        # Use V2 endpoint
        $authUrl = "$Instance/$Tenant/oauth2/v2.0/token"
    }

    else {
        # Use V1 endpoint
        $authUrl = "$Instance/$Tenant/oauth2/token"
        $body.resource = "$ResourceId"
    }

    $token.authUrl = $authUrl

    $body.client_id  = $ClientID
    $body.grant_type = $GrantType
    $body.scope      = $scopes
    $body.nonce      = 1234
    $body.state      = 5678

    if ($ReplyAddress)
    {
        $body.redirect_uri = $ReplyAddress
    }

    if ($RefreshToken)
    {
        $body.refresh_token = $RefreshToken
    }

    if ($ClientSecret) {
        $body.client_secret = $ClientSecret
    }

    if ($Username -and $Password) {
        $body.username   = $Username
        $body.password   = $Password
        $body.grant_type = "password"
    }

    $token.PostContent = $body

    # Sign-in to Azure AD & Get Access Token
    try {
        Write-Verbose "Authenticating to '$authUrl'"
        
        $response = $null
        $response      = Invoke-WebRequest -Method Post -Uri $authUrl -Body $body -verbose

        $content = $null

        if($response.content) {
            $content = $response.content | ConvertFrom-Json
        }
        elseif($response.access_token) {
            $content = $response
        }

        if ($content.access_token)   { $token.AccessToken = $content.access_token }
        if ($content.id_token)       { $token.IdToken = $content.id_token }
        if ($content.refresh_token)  { $token.RefreshToken = $content.refresh_token }
        if ($content.Type)           { $token.Type = $content.Type }
        if ($content.scope)          { $token.scope = $content.scope }
        if ($content.expires_in)     { $token.expires_in = $content.expires_in }
        if ($content.ext_expires_in) { $token.ext_expires_in = $content.ext_expires_in }
        if ($content.expires_on)     { $token.expires_on = $content.expires_on }
        if ($content.not_before)     { $token.not_before = $content.not_before }
        if ($content.resource)       { $token.resource = $content.resource }

        if($IdToken) {
            Write-Verbose ""
            Write-Verbose "++++++++++++++++++++++++++++"
            Write-Verbose "ID Token"
            Write-Verbose ""
            Write-Verbose $IdToken
            Write-Verbose ""
        }

        if($AccessToken) {
            Write-Verbose ""
            Write-Verbose "++++++++++++++++++++++++++++"
            Write-Verbose "Access Token"
            Write-Verbose ""
            Write-Verbose $AccessToken
            Write-Verbose ""
        }
    }

    # Acquire token failed
    Catch {
        
        $scriptError = $_
        $scriptError = $scriptError | ConvertFrom-Json

        $token.Error = $scriptError

        # AADSTS65001
        if ($scriptError -match "AADSTS65001") {
            $consentUrl = "$Instance/$Tenant/oauth2/authorize?client_id=$ClientId&response_type=code&redirect=$RedirectUri&prompt=admin_consent"
            Write-Host ""
            Write-Host "Consent Required" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Go to the following url '$consentUrl'" -ForegroundColor Yellow
        }

        # AADSTS50079
        if ($scriptError -match "AADSTS50079") {

            $claims = $scriptError.claims | ConvertFrom-Json
            $capolids = $claims.access_token.capolids.values

            Write-Host ""
            Write-Host "User Interaction Required due to Conditional Access Policy Id '$capolids'" -ForegroundColor Yellow

        }

        return $token
    }

    $Headers = @{ "Authorization" = "Bearer $AccessToken" }
    $token.Headers = $Headers

    $Object = New-Object PSObject -Property $token

    return $Object
}
Export-ModuleMember -Function Get-AadToken


# ##############################################################################################
# HELPER FUNCTIONS
# ##############################################################################################

function ConvertFrom-AadJwtToken {
 
    [cmdletbinding()]
    param([Parameter(ValueFromPipeline = $true,Mandatory=$true)][string]$token)
 
    #Validate as per https://tools.ietf.org/html/rfc7519
    #Access and ID tokens are fine, Refresh tokens will not work
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
    
    $jwtClaims = @{}

    #Header
    $tokenheader = $token.Split(".")[0]
    
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) { $tokenheader += "=" }
    
    #Convert from Base64 encoded string to PSObject all at once
    $jwtHeader = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json)

    $jwtHeader.psobject.properties | Foreach { $jwtClaims[$_.Name] = $_.Value }

    #Payload
    $tokenPayload = $token.Split(".")[1]
    
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenPayload.Length % 4) { $tokenPayload += "=" }
    
    #Convert from Base64 encoded string to PSObject all at once
    $jwtPayload = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenPayload)) | ConvertFrom-Json)

    $jwtPayload.psobject.properties | Foreach { $jwtClaims[$_.Name] = $_.Value }

    $Object = New-Object PSObject -Property $jwtClaims

    return $Object
}
Export-ModuleMember -Function ConvertFrom-AadJwtToken


# ##############################################################################################
# CLIENT ASSERTION
# ##############################################################################################
function ClientAssertion 
{
    param($ClientId, $ClientSecret, $ClientAssertion)

    $body            = @{}
    $body.client_id  = $ClientId
    $body.client_secret  = $ClientSecret
    $body.refresh_token  = [System.Web.HttpUtility]::UrlEncode($RefreshToken)
    $body.grant_type = "refresh_token"

    try {
        Write-Host "Authenticating to '$authUrl'" -ForegroundColor Yellow
        $body | ft
        
        $response = $null
        $response      = Invoke-WebRequest -Method Post -Uri $authUrl -Body $body -verbose
    
        $content = $null
    
        if($response.content) {
            $content = $response.content | ConvertFrom-Json
        }
        elseif($response.access_token) {
            $content = $response
        }
        
        $AccessToken = $null
        $AccessToken = $content.access_token
    
        if($AccessToken) {
            Write-Host "Acquired Access Token successfull!"
        }
    }

    Catch {
        $scriptError = $_
    
        if ($response) {
            $scriptError = $scriptError | ConvertFrom-Json
            $scriptError
        } 
        else {
                throw $scriptError
        }
    }
}
