<#
.SYNOPSIS
Get Access Token from Azure AD token endpoint. 

.DESCRIPTION
Get Access Token from Azure AD token endpoint. 

.PARAMETER ClientId
Provide Client ID or App ID required to get a access token

.PARAMETER ResourceId
Provide App URI ID or Service Principal Name you want to get an access token for.

.PARAMETER Scopes
Provide Scopes for the request.

.PARAMETER ClientSecret
Provide Client Secret if this is a Web App client.

.PARAMETER Redirect
Provide Redirect URI or Redirect URL.

.PARAMETER Username
Provide username if using Resource Owner Password grant flow.

.PARAMETER Password
Provide Password of resource owner if using Resource Owner Password Credential grant flow.

.PARAMETER Tenant
Provide Tenant ID you are authenticating to.

.PARAMETER Instance
Provide Azure AD Instance you are connecting to.

.PARAMETER UseV2
By default, Azure AD V1 authentication endpoints will be used. Use this if you want to use the V2 Authentication endpoints.

.PARAMETER UseResourceOwner
Enable this switch if you want to use the Resource Owner Password Credential grant flow.

.PARAMETER UseClientCredential
Enable this switch if you want to use the Client Credential grant flow.

.PARAMETER UseRefreshToken
Enable this switch if you want to use the Refresh Token grant flow.

.PARAMETER GrantType
Specify the 'grant_type' you want to use.
 - password
 - client_credentials
 - refresh_token
 - authorization_code
 - urn:ietf:params:oauth:grant-type:jwt-bearer
 - urn:ietf:params:oauth:grant-type:saml1_1-bearer
 - urn:ietf:params:oauth:grant-type:saml2-bearer

.PARAMETER Code
Specify the 'code' for authorization code flow

.PARAMETER Assertion
Specify the 'assertion' you want to use for user assertion

.PARAMETER ClientAssertionType
Specify the 'client_assertion_type' you want to use.

Available options...
 - urn:ietf:params:oauth:client-assertion-type:jwt-bearer

.PARAMETER ClientAssertion
Specify the 'client_assertion' you want to use. This is used for Certificate authentication where the client assertion is signed by a private key.

.PARAMETER RequestedTokenUse
Specify the 'requested_token_use' you want to use. For Azure AD, the only acceptable value is 'on_behalf_of'. This is used to identify the on-behalf-of flow is to be used.

.PARAMETER RequestedTokenType
Specify the 'requested_token_type'. This is either... 
 - urn:ietf:params:oauth:token-type:saml2
 - urn:ietf:params:oauth:token-type:saml1

.EXAMPLE
Use Resource Owner Password Credential grant flow
Get-AadToken -UseResourceOwner -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -Redirect "https://login.microsoftonline.com/common/oauth2/nativeclient" -Username john@contoso.com -Password P@$$w0rd!

To get client only access token
Get-AadToken -UseClientCredential -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -ClientSecret "98iwjdc-098343js="

.NOTES
General notes
#>

function Get-AadToken
{
    [CmdletBinding(DefaultParameterSetName="All")] 
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ClientId,

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$false)]
        [switch]$UseResourceOwner,

        [Parameter(ParameterSetName="UseClientCredential", Mandatory=$false)]
        [switch]$UseClientCredential,

        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$false)]
        [switch]$UseRefreshToken,   

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$true)]
        [string]$Username = $null,

        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$true)]
        [string]$Password = $null,


        [string]$ClientSecret = $null,

        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$true)]
        [string]$RefreshToken,

        [string]$ResourceId = "https://graph.microsoft.com",
        
        [Parameter(ParameterSetName="UseClientCredential", Mandatory=$true)]
        [Parameter(ParameterSetName="UseRefreshToken", Mandatory=$false)]
        [Parameter(ParameterSetName="UseResourceOwner", Mandatory=$false)]
        [string]$Tenant,

        [string]$Scopes = "openid email profile offline_access https://graph.microsoft.com/.default",
        [string]$Redirect = $null,
        [string]$Instance = "https://login.microsoftonline.com",
        
        [switch]$UseV2 = $false,

        [string]$GrantType,
        [string]$Code,
        [string]$Assertion,
        [string]$ClientAssertionType,
        [string]$ClientAssertion,
        [string]$RequestedTokenUse,

        [ValidateSet("urn:ietf:params:oauth:token-type:saml2", "urn:ietf:params:oauth:token-type:saml1")]
        [string]$RequestedTokenType
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $error.Clear()
    $scriptError = $null

    # Get Service Principal
    try {
        $sp = Get-AadServicePrincipal -Id $ClientId

        # Get real Client ID
        $ClientId = $sp.AppId
    }
    catch {
        Write-Host "App '$ClientId' not found" -ForegroundColor Yellow
    }


    if($sp.count -gt 1)
    {
        throw "Found too many results for '$ClientId'. Please specify a unique ClientId."
    }


    # Get Redirect Uri if not one specified
    if(-not $Redirect -and $sp) 
    {
        $Redirect = $sp.ReplyUrls[0]
    }
    

    # Set Grant_Type
    if (-not $UseResourceOwner -and -not $UseClientCredential -and -not $UseRefreshToken -and -not $GrantType)
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

    # Requirements for Resource Owner
    if ($UseResourceOwner)
    {
        $GrantType = "password"
        
        if (-not $Username)
        {
            $Username = Read-Host -Prompt "Username"
        }

        if (-not $Password)
        {
            $Password = Read-Host -Prompt "Password"
        }
    }

    # Requirements for ClientCredentials
    if($UseClientCredential)
    {
        $GrantType = "client_credentials"

        if (-not $Tenant -or $Tenant -eq "common")
        {
            $Tenant = Read-Host -Prompt "Tenant (Do not use 'common')"
        }

        if (-not $ClientSecret)
        {
            $ClientSecret = Read-Host -Prompt "ClientSecret"
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


    # Lookup Resource
    try {
        $resource = Get-AadServicePrincipal -Id $ResourceId
        $ResourceId - $resource.AppId
    }
    catch {
        Write-Host "Resource '$ResourceId' not found" -ForegroundColor Yellow
    }


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

    if ($Redirect)
    {
        $body.redirect_uri = $Redirect
    }

    if ($RefreshToken)
    {
        $body.refresh_token = $RefreshToken
    }

    if($Code)
    {
        $body.code = $Code
    }

    if ($ClientSecret) {
        $body.client_secret = $ClientSecret
    }

    if ($Username -and $Password) {
        
        $body.username   = $Username
        $body.password   = $Password
        $body.grant_type = "password"
    }

    if($ClientAssertionType)
    {
        $body.client_assertion_type = $ClientAssertionType
    }

    if($ClientAssertion)
    {
        $body.client_assertion = $ClientAssertion
    }

    if($Assertion)
    {
        $body.assertion = $Assertion
    }

    if($RequestedTokenUse)
    {
        $body.requested_token_use = $RequestedTokenUse
    }

    if($RequestedTokenType)
    {
        $body.requested_token_type = $RequestedTokenType
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
        if ($content.scope)          { $token.Scopes = $content.scope }
        if ($content.expires_in)     { $token.expires_in = $content.expires_in }
        if ($content.ext_expires_in) { $token.ext_expires_in = $content.ext_expires_in }
        if ($content.expires_on)     { $token.expires_on = $content.expires_on }
        if ($content.not_before)     { $token.not_before = $content.not_before }
        if ($content.resource)       { $token.resource = $content.resource }

        if($token.AccessToken)
        {
            if($token.AccessToken.StartsWith("eyJ"))
            {
                $token.AccessTokenClaims = $token.AccessToken | ConvertFrom-AadJwtToken
            }

            else 
            {
                $token.SamlDecoded = ConvertFrom-Base64String -base64String ( Base64UrlDecode($token.AccessToken) )
            }
            
        }

        if($token.IdToken)
        {
            $token.IdTokenClaims = $token.IdToken | ConvertFrom-AadJwtToken
        }
    }

    # Acquire token failed
    Catch {
        
        $scriptError = $_
        $scriptError = $scriptError | ConvertFrom-Json

        $token.Error = $scriptError
        $scriptError | Out-Host

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

    

    $Object = New-Object PSObject -Property $token

    if($Object.AccessTokenClaims -and -not $HideOutput)
    {
        
        Write-Host ""
        Write-Host "Access Token" -ForegroundColor Yellow
        Write-ObjectToHost $($Object.AccessTokenClaims)
    }
    
    
    return $Object
}






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
