# ----------------------------------------------------------------------------
# INFORMATION
# * Used the follow resource as a guide to write this script
#   https://github.com/kenakamu/Microsoft.ADAL.PowerShell/blob/master/Microsoft.ADAL.PowerShell/Microsoft.ADAL.PowerShell.psm1
# * At the time of writing this...
#   > AzureAD Module Version (AzureAdPreview version 2.0.1.18)
#   > Active Directory Authentication Library version 3.19.7

# ----------------------------------------------------------------------------
<#
# SAMPLE USAGE

    # CONFIGURATION
    $TenantName  = "williamfiddes.onmicrosoft.com"
    $RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
    $ResourceId  = "https://graph.microsoft.com"

    # If using Native app type
    $ClientID    = ""
    
    # If using Web app type
    $ClientID    = ""
    $ClientSecret = ""

    # ACQUIRE TOKEN
    $aadContext = [AadContext]::new()
    $aadContext.TenantName = $TenantName
    $aadContext.AcquireToken($ResourceId,$ClientId,$RedirectURI,$PromptBehavior)
    #$aadContext.AcquireToken($Resource, $ClientId, $ClientSecret)
    $Headers = $aadContext.CreateAuthenticationHeaders()
#>

<#
.SYNOPSIS
Gets a token using ADAL installed with Azure AD PowerShell Module


.DESCRIPTION
Gets a token using ADAL installed with Azure AD PowerShell Module
Prompts user to sign-in in order to acquire token.

ClientID          : "ApplicationId-of-the-client-application"
TenantId          : "tenant-id"
AccessTokenClaims : @{ access-token-claims }
Scopes            : "scopes-in-access-token"
ExtraQueryParams  : "extra-query-parameters-used-to-get-token"
UserId            : "login_hint"
PromptBehavior    : "prompt-behavior-used-to-get-token"
ExpiresOn         : "when-the-token-expires"
Authority         : "authority"
IdToken           : "id-token"
IdTokenClaims     : @{ claims-in-the-id-token }
UniqueId          : "object-id-of-the-user"
ReplyAddress      : "reply-address-of-client-application"
AccessToken       : "access-token"
DisplayableId     : "user-principal-name-of-user"
AppId             : "ApplicationId-of-the-client-application"
Audience          : "ApplicationId-of-the-resource"
Resource          : "ApplicationId-of-the-resource"
Roles             : "roles-in-the-token"

.PARAMETER ResourceId
Set the resource in which you want to get a access token for

.PARAMETER ClientId
Set the Client ID/App Id in which you want to get a access token from

.PARAMETER Redirect
Set the Redirect URL/URI for which Azure AD will redirect back to your application

.PARAMETER Prompt
Sets the prompt behavior for ADAL
'Always','Auto','SelectAccount','RefreshSession','Never'

.PARAMETER UserId
Sets the user account to use when authenticating

.PARAMETER Password
Sets the password for the user account being used if using the Resource Owner Password Credential method

.PARAMETER Tenant
Sets the tenant in which your authenticating to
Used in conjunction with Instance to form the Authority

.PARAMETER Instance
Sets the Azure AD Instance tenant in which your authenticating to
Used in conjunction with Tenant to form the Authority

.PARAMETER UseClientCredential
Tell ADAL to use the Client Credential flow (Gets a client only access token)

.PARAMETER UseResourceOwnerPasswordCredential
Tell ADAL to use the UserPasswordCredential method. This is actually the Windows Integrated Authentication extension method in ADAL and can also be used for the Resource Owner Password Credential flow for non-federated users.

.PARAMETER ClientSecret
Sets the Client Secret for ADAL to use during Client Credential flow

.EXAMPLE
Prompt user to sign-in to get access token
Get-AadTokenUsingAdal -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Native App' -Redirect "https://login.microsoftonline.com/common/oauth2/nativeclient"

To get client only access token
Get-AadTokenUsingAdal -UseClientCredential -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Service App' -ClientSecret "98iwjdc-098343js="

Use the Resource Owner Password Credential Flow or us WIA (Password required)
Get-AadTokenUsingAdal -UseResourceOwnerPasswordCredential -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Service App' -UserId 'your-user-name' -Password "your-secret-password"


.NOTES
General notes
#>

function Get-AadTokenUsingAdal
{
    [CmdletBinding(DefaultParameterSetName="All")] 
    param(
        [Parameter(Mandatory=$true,Position=0)]
        $ClientId,

        $ResourceId = $($Global:AadSupport.Resources.MsGraph),

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$false)]
        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$false)]
        $Redirect,

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$false)]
        [Parameter(ParameterSetName="RopcFlow", Mandatory=$true)]
        $UserId,

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$false)]
        [Parameter(ParameterSetName="RopcFlow", Mandatory=$true)]
        $Password,

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$false)]
        $DomainHint,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Always','Auto','SelectAccount','RefreshSession','Never')]
        $Prompt,

        $Tenant,
        $Instance,

        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$true)]
        [switch]
        $UseClientCredential,

        [Parameter(ParameterSetName="RopcFlow", Mandatory=$true)]
        [switch]
        $UseResourceOwnerPasswordCredential,

        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$true)]
        $ClientSecret,

        [switch]
        $SkipServicePrincipalSearch,

        [switch]
        $HideOutput
    )

    # Convert Password string to SecuredString
    if($Password)
    {
        [SecureString]$SecuredPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    }

    "Get-AadTokenUsingAdal::Params:Instance:$Instance" | Log-AadSupport
    if(-not $Instance)
    {
        if($Global:AadSupport.Session.AadInstance)
        {
            $Instance = $Global:AadSupport.Session.AadInstance
        }
        else 
        {
            $Instance = "https://login.microsoftonline.com"
        }
    }
    
    if(-not $Tenant)
    {
        if($Global:AadSupport.Session.TenantId)
        {
            $Tenant = $Global:AadSupport.Session.TenantId
        }
        else 
        {
            $Tenant = "common"
        }
    }

    # Get Service Principal
    if(-not $SkipServicePrincipalSearch -and $Global:AadSupport.Session.Active)
    {
        try{
            $sp = Get-AadServicePrincipal -Id $ClientId
            $ClientId = $sp.AppId
        }
        catch {
            Write-Host "App '$ClientId' not found" -ForegroundColor Yellow
        }
        
        if(-not $Redirect -and $sp)
        {
            $Redirect = $sp.ReplyUrls[0]
        }

        # Lookup Resource
        try {
            $resource = Get-AadServicePrincipal -Id $ResourceId
            $ResourceId = $resource.AppId
        }
        catch {
            Write-Host "Resource '$ResourceId' not found" -ForegroundColor Yellow
        }
        
    }    

    if($sp.count -gt 1)
    {
        throw "Found too many results for '$ClientId'. Please specify a unique ClientId."
    }

    if(-not $UserId -and -not $Prompt)
    {
        $UserId = $Global:AadSupport.Session.AccountId
    }

    $ExtraQueryParams = ""
    if ($UserId)
    {
        $ExtraQueryParams += "&login_hint=$UserId"
    }
    if ($DomainHint)
    {
        $ExtraQueryParams += "&domain_hint=$DomainHint"
    }


    # Use the Client Credential Flow
    if ($UseClientCredential)
    {
        if($Tenant -eq "common")
        {
            throw "Invalid Tenant. When using Client Credentials, Tenant is required."
        }
         
        $result = Invoke-AdalCommand -Command { 
            Param($Params)
                
            $result = Get-AadSupportTokenForClient -Authority $Params.Authority -ClientId $Params.ClientId -ResourceId $Params.ResourceId -ClientSecret $Params.ClientSecret
            return $result
        } -Parameters @{
            Authority = "$Instance/$Tenant/"
            ResourceId = $ResourceId
            ClientId = $ClientId 
            ClientSecret = $ClientSecret
        }

    }

    # Use the Resource Owner Password Credential Flow
    if($UseResourceOwnerPasswordCredential)
    {
        $result = Invoke-AdalCommand -Command { 
            Param($Params)
            $result = Get-AadSupportTokenForUserWithPassword -Authority $Params.Authority -ClientId $Params.ClientId -ResourceId $Params.ResourceId -UserId $Params.UserId -Password $Params.Password
            return $result
        } -Parameters @{
            ClientId = $ClientId 
            ResourceId = $ResourceId
            UserId = $UserId
            Password = $SecuredPassword
            Authority = "$Instance/$Tenant/"
        }
    }

    # Determine and use a Interactive flow
    if (-not $UseClientCredential -and -not $UseResourceOwnerPasswordCredential)
    {

        Write-Verbose "Use Interactive flow."
        if($Prompt -ne "Always" -and $Prompt -ne "SelectAccount")
        {
            $result = Invoke-AdalCommand -Command { 
                Param($Params)
                    
                $result = Get-AadSupportTokenForUser -Authority $Params.Authority -ClientId $Params.ClientId -ResourceId $Params.ResourceId -RedirectURI $Params.RedirectURI -PromptBehavior $Params.Prompt -ExtraQueryParameters $Params.ExtraQueryParameters -UserId $Params.UserId
                return $result
            } -Parameters @{
                ClientId = $ClientId 
                ResourceId = $ResourceId
                RedirectURI = $Redirect
                UserId = $UserId
                ExtraQueryParameters = $ExtraQueryParams
                Prompt = $Prompt
                Authority = "$Instance/$Tenant/"
            }
            
        }

        else {
            Write-Host "Authenticating user..." -ForegroundColor Yellow

            $result = Invoke-AdalCommand -Command { 
                Param($Params)
                $result = Get-AadSupportTokenForUser -Authority $Params.Authority -ClientId $Params.ClientId -ResourceId $Params.ResourceId -RedirectURI $Params.RedirectURI -PromptBehavior $Params.Prompt
                return $result
                
            } -Parameters @{
                Authority = "$Instance/$Tenant/"
                ClientId = $ClientId 
                ResourceId = $ResourceId
                RedirectURI = $Redirect
                Prompt = $Prompt
            }

        }
        
    }

    $details = @{}
    $details.AppId = $ClientId
    $details.ReplyAddress = $Redirect
    $details.Audience = $ResourceId

    if($result.Error -or $result.Exception)
    {

        $details.Error = $result.ErrorDetails.Exception.Message

        if (-not $HideOutput)
        {
            Write-Host ""
            Write-Host "Error" -ForegroundColor Yellow
            $AadError = $details.Error.Message
            Write-Host $AadError -ForegroundColor Red

            # If Output is allowed, lets return the error
            return $details
        }

        #Otherwise throw the error to stop the program
        return $result.Exception
    }

    foreach($member in $result | Get-member)
    {
        if ($member.MemberType -eq 'NoteProperty')
        {
            $details[$member.Name] = $result.($member.Name)

        }
        
    }

    $Headers = @{ "Authorization" = "Bearer $($details.AccessToken)" }
    $details.Headers = $Headers
    $details.AccessTokenClaims = $details.AccessToken | ConvertFrom-AadJwtToken
    $details.Scopes = $details.AccessTokenClaims.scp
    $details.Roles = $details.AccessTokenClaims.Roles
    if($details.IdToken) { $details.IdTokenClaims = $details.IdToken | ConvertFrom-AadJwtToken }

    $Object = New-Object -TypeName PSObject -Property $details
    
    if($Object.AccessToken -and -not $HideOutput)
    {
        
        Write-Host ""
        Write-Host "Access Token" -ForegroundColor Yellow
        $AccessTokenClaims = $Object.AccessTokenClaims
        Write-ObjectToHost $AccessTokenClaims
    }

    return $Object
        
       
    #}

    //Write-Host "RUNNING Invoke-AdalCommand"
    //Invoke-AdalCommand -Command $ScriptBlock -Parameters $Params

    Write-Host "END Invoke-AdalCommand"
}

function Test-GetAadTokenUsingAdal {
    Get-AadTokenUsingAdal -UseClientCredential -ClientId 'aadsupport unittest' -ResourceId 'Microsoft Graph' -ClientSecret 'iu?6uN35Mp9b?]]KqMwnpElTBy.S:/5-' -Tenant williamfiddes.onmicrosoft.com
    
}

# ############################################################################
# FEATURE REQUESTS
#
# $AdalAssembly = Allow to set custom Adal Assembly path
# Implement AcquireToken using user credentials
# Implement AcquireToken using OBO
# Implement Options to set additional parameters
#   > AAD Instance
#   > Set login_hint
#   > Set domain_hint
#   > Set Prompt Behavior