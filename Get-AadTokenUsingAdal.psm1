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

.PARAMETER ResourceId
Set the resource in which you want to get a access token for

.PARAMETER ClientId
Set the Client ID/App Id in which you want to get a access token from

.PARAMETER Redirect
Set the Redirect URL/URI for which Azure AD will redirect back to your application

.PARAMETER Prompt
Sets the prompt behavior for ADAL
'Always','Auto','SelectAccount','RefreshSession','Never'

.PARAMETER Tenant
Sets the tenant in which your authenticating to
Used in conjunction with Instance to form the Authority

.PARAMETER Instance
Sets the Azure AD Instance tenant in which your authenticating to
Used in conjunction with Tenant to form the Authority

.PARAMETER UseClientCredential
Tell ADAL to use the Client Credential flow (Gets a client only access token)

.PARAMETER ClientSecret
Sets the Client Secret for ADAL to use during Client Credential flow

.EXAMPLE
Prompt user to sign-in to get access token
Get-AadTokenUsingAdal -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -Redirect "https://login.microsoftonline.com/common/oauth2/nativeclient"

To get client only access token
Get-AadTokenUsingAdal -UseClientCredential -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -ClientSecret "98iwjdc-098343js="

.NOTES
General notes
#>

function Get-AadTokenUsingAdal
{
    [CmdletBinding(DefaultParameterSetName="All")] 
    param(
        [Parameter(Mandatory=$true)]
        $ResourceId,

        [Parameter(Mandatory=$true)]
        $ClientId,

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$true)]
        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$false)]
        $Redirect,

        [Parameter(ParameterSetName="UserAccessToken", Mandatory=$false)]
        $UserId,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Always','Auto','SelectAccount','RefreshSession','Never')]
        $Prompt = 'Always',

        $Tenant = "common",

        $Instance = "https://login.microsoftonline.com",

        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$true)]
        [switch]
        $UseClientCredential,

        [Parameter(ParameterSetName="ClientAccessToken", Mandatory=$true)]
        $ClientSecret
    )

    
    $aadContext = [AadContext]::new()
    $aadContext.TenantName = $Tenant
    $aadContext.AadInstance = $Instance

    if ($UseClientCredential)
    {
        if($Tenant -eq "common")
        {
            throw "Invalid Tenant. When using Client Credentials, Tenant is required."
        }

        $result = $aadContext.AcquireToken($ResourceId,$ClientId,$ClientSecret) | ConvertFrom-Json
    }
    else 
    {
        try {
            $result = $aadContext.AcquireSilentToken($ResourceId,$ClientId,$UserId) | ConvertFrom-Json
        }
        catch{
            $result = $aadContext.AcquireToken($ResourceId,$ClientId,$Redirect,$Prompt) | ConvertFrom-Json
        }
        
    }

    $details = @{}
    foreach($member in $result | Get-member)
    {
        if ($member.MemberType -eq 'NoteProperty')
        {
            $details[$member.Name] = $result.($member.Name)

        }
        
    }

    $Object = New-Object -TypeName PSObject -Property $details
    return $Object
}


# ----------------------------------------------------------------------------
# AadContext (AAD Helper Class)

class AadContext {
    [string]$TenantName
    [string]$ClientID
    [string]$Redirect
    [string]$ResourceId 

    [string]$AadInstance = "https://login.microsoftonline.com"

    $AdalAssembly = $null
    [string]$AccessToken

    AadContext() {
    }


    # ----------------------------------------------------------------------------
    # AcquireToken
    # Method to help get Azure AD tokens (Interactive flow)
    [string]AcquireToken([string]$_ResourceId, [string]$_ClientID, [string]$_RedirectURI, [string]$_PromptBehavior)
    {
        $_TenantName = $this.TenantName
        $_AadInstance = $this.AadInstance 
        
        $result = @{}

        if($null -eq $_TenantName -or $_TenantName -eq "")
        {
            $result.Error = "Tenant Name required!"
            return $result
        }

        if($null -eq $_ClientID -or $_ClientID -eq "")
        {
            $result.Error = "Client ID required!"
            return $result
        }

        if($null -eq $_RedirectURI -or $_RedirectURI -eq "")
        {    
            $result.Error = "Redirect URI required!"
            return $result
        }   
        if($null -eq $_ResourceId -or $_ResourceId -eq "")
        {    
            $result.Error = "Resource Id required!"
            return $result
        }
        if($_PromptBehavior -ne "Always" -and $_PromptBehavior -ne "Auto" -and $_PromptBehavior -ne "SelectAccount" -and $_PromptBehavior -ne "Never" -and $_PromptBehavior -ne "RefreshSession")
        {    
            $result.Error = "Prompt Behavior required!"
            return $result
        }
        
        $promptBehavior = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior"


        #Build the logon URL with the tenant name
        $authority = "$_AadInstance/$_TenantName"
        Write-Verbose "Logon Authority: $authority"

        #Build the auth context and get the result
        $authContext = $null
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
        
        $authResult = $null

        $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList $promptBehavior::$_PromptBehavior
        write-verbose "Authenticating... "

        Try
        {
            
            $request = $authContext.AcquireTokenAsync($_ResourceId, $_ClientId, $_RedirectUri, $platformParameters)
            
            #$userId = "admin@williamfiddes.onmicrosoft.com"
            #$authResult =  $authContext.AcquireTokenAsync($_ResourceId, $_ClientId, $_RedirectUri, $platformParameters, $userId)
            $result = $request.GetAwaiter().GetResult()

            if ($result.Exception -ne $null) {
                Write-Output "Exception: " $result.Exception
            }

        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            $result.Error = $_
            return $result
        }

        
    
        #Return the authentication token
        return ($result | ConvertTo-Json)
    }


    # ----------------------------------------------------------------------------
    # AcquireToken - CLIENT CREDENTIALS
    [string]AcquireToken([string]$_ResourceId, [string]$_ClientID, [string]$_ClientSecret)
    {
        $_TenantName = $this.TenantName
        $_AadInstance = $this.AadInstance

        if($null -eq $_TenantName -or $_TenantName -eq "")
        {
            throw "Tenant Name required!"
        }

        if($null -eq $_ClientID -or $_ClientID -eq "")
        {
            throw "Client ID required!"
        }

        if($null -eq $_ClientSecret -or $_ClientSecret -eq "")
        {    
            throw "Client Secret required!"
        }   
        if($null -eq $_ResourceId -or $_ResourceId -eq "")
        {    
            throw "Resource Id required!"
        }

        #Build the logon URL with the tenant name
        $authority = "$_AadInstance/$_TenantName"
        Write-Verbose "Logon Authority: $authority"
    
        #Build the auth context and get the result
        $authContext = $null
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

        $AdClientCreds = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential" -ArgumentList $_ClientID, $_ClientSecret
        
        Write-Verbose "Attempting client credentials authentication"
        try {
            $request = $authContext.AcquireTokenAsync($_ResourceId, $AdClientCreds)

            $result = $request.GetAwaiter().GetResult()
        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            throw $_
        }

        #Return the authentication token
        return ($result | ConvertTo-Json)
    }


        # ----------------------------------------------------------------------------
    # AcquireToken - CLIENT CREDENTIALS
    [string]AcquireSilentToken([string]$_ResourceId, [string]$_ClientID, [string]$_UserId)
    {
        $_TenantName = $this.TenantName
        $_AadInstance = $this.AadInstance

        if($null -eq $_ClientID -or $_ClientID -eq "")
        {
            throw "Client ID required!"
        }
  
        if($null -eq $_ResourceId -or $_ResourceId -eq "")
        {    
            throw "Resource Id required!"
        }

        if(-not $_UserId)
        {
            $UserIdentifier = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier]::AnyUser
        }
        else 
        {
            $UserType = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifierType]::RequiredDisplayableId 
            $UserIdentifier = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList $_UserId,$UserType 
        }

        #Build the logon URL with the tenant name
        $authority = "$_AadInstance/$_TenantName"
        Write-Verbose "Logon Authority: $authority"
    
        #Build the auth context and get the result
        $authContext = $null
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

        
        Write-Verbose "Attempting client credentials authentication"
        try {
            $request = $authContext.AcquireTokenSilentAsync($_ResourceId, $_ClientID, $UserIdentifier)

            $result = $request.GetAwaiter().GetResult()
        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            throw $_
        }

        #Return the authentication token
        return ($result | ConvertTo-Json)
    }


    [hashtable]CreateAuthenticationHeaders() {
        return @{ "Authorization" = "Bearer "+$this.AccessToken }
    }

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