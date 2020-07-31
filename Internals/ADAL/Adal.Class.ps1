# ----------------------------------------------------------------------------
# AadContext (AAD Helper Class)
# 

class AadContext {
    [string]$TenantName
    [string]$ClientID
    [string]$Redirect
    [string]$ResourceId 

    [string]$AadInstance = "https://login.microsoftonline.com"

    [string]$AccessToken
    
    [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authContext = $null

    AadContext($authority) {
        #Build the auth context and get the result
        $TokenCache = New-Object -TypeName "Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache"
        $this.authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority, $TokenCache
        
    }


    # ----------------------------------------------------------------------------
    # AcquireToken
    # Method to help get Azure AD tokens (Interactive flow)
    [string]AcquireToken([string]$_ResourceId, [string]$_ClientID, [string]$_RedirectURI, [string]$_PromptBehavior, [string]$_UserId, [string]$_ExtraQueryParams)
    {
        
        $ReturnObject = @{}
        $ReturnObject.Resource = $_ResourceId
        $ReturnObject.ClientID = $_ClientID
        $ReturnObject.PromptBehavior = $_PromptBehavior
        $ReturnObject.UserId = $_UserId
        $ReturnObject.ExtraQueryParams = $_ExtraQueryParams
        
        if($null -eq $_RedirectURI -or $_RedirectURI -eq "")
        {    
            $_RedirectURI = "https://login.microsoftonline.com/common/oauth2/nativeclient"
        }   

        if(-not $_PromptBehavior)
        {    
            $_PromptBehavior = "Auto"
        }
        
        $promptBehavior = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior"

        
        # Set UserIdentifier
        $UserIdentifier = $null
        if($_UserId)
        {
            $UserType = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifierType]::RequiredDisplayableId 
            $UserIdentifier = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList $_UserId,$UserType 
        }

        # If UserIdentifier not set yet from above...
        if(-not $UserIdentifier)
        {
            $UserIdentifier = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier]::AnyUser
        }

        $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList $promptBehavior::$_PromptBehavior

        Try
        {
            

            if($_UserId -and $_ExtraQueryParams)
            {
                $RebuildQueryParams = @()
                $SplitQueryParams = $_ExtraQueryParams.Split("&")


                foreach($item in $SplitQueryParams)
                {
                    if(-not ($item -match "login_hint")) 
                    {
                        $RebuildQueryParams += $item
                    }
                }

                $_ExtraQueryParams = $RebuildQueryParams -join "&"
            }

            if(-not $_RedirectURI) {$_RedirectURI = $null}

            $request = $this.authContext.AcquireTokenAsync($_ResourceId, $_ClientID, $_RedirectURI, $platformParameters, $UserIdentifier, $_ExtraQueryParams)
            $result = $request.GetAwaiter().GetResult()
            $ReturnObject.AccessToken = $result.AccessToken
            $ReturnObject.Authority = $result.Authority
            $ReturnObject.IdToken = $result.IdToken
            $ReturnObject.TenantId = $result.TenantId
            $ReturnObject.ExpiresOn = $result.ExpiresOn.ToString()
            $ReturnObject.DisplayableId = $result.UserInfo.DisplayableId
            $ReturnObject.UniqueId = $result.UserInfo.UniqueId

        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            $ReturnObject.Error = $true
            $ReturnObject.ErrorDetails = $_
        }

    
        #Return the authentication token
        return ($ReturnObject | ConvertTo-Json)
    }


    # ----------------------------------------------------------------------------
    # AcquireToken - CLIENT CREDENTIALS
    [string]AcquireToken([string]$_ResourceId, [string]$_ClientID, [string]$_ClientSecret)
    {
        $ReturnObject = @{}
        $ReturnObject.Resource = $_ResourceId
        $ReturnObject.ClientID = $_ClientID

        $_AadInstance = $this.AadInstance


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
    
        
        $AdClientCreds = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential" -ArgumentList $_ClientID, $_ClientSecret
        
        Write-Verbose "Attempting client credentials authentication"
        $result = @{}
        try {
            $request = $this.authContext.AcquireTokenAsync($_ResourceId, $AdClientCreds)
            $result = $request.GetAwaiter().GetResult()
            $ReturnObject.AccessToken = $result.AccessToken
            $ReturnObject.Authority = $result.Authority
            $ReturnObject.IdToken = $result.IdToken
            $ReturnObject.TenantId = $result.TenantId
            $ReturnObject.ExpiresOn = $result.ExpiresOn.ToString()
        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            $ReturnObject.Error = $true
            $ReturnObject.ErrorDetails = $_
        }

        #Return the authentication token
        return ($ReturnObject | ConvertTo-Json)
    }


    # ----------------------------------------------------------------------------
    # AcquireTokenUsingUsernameAndPassword
    # Method to help get Azure AD tokens (Interactive flow)
    [string]AcquireTokenUsingUsernameAndPassword([string]$_ResourceId, [string]$_ClientID, [string]$_UserId, [SecureString]$_Password)
    {
        
        "STARTING::AcquireTokenUsingUsernameAndPassword" | Log-AadSupportRunspace

        $ReturnObject = @{}
        $ReturnObject.Resource = $_ResourceId
        $ReturnObject.ClientID = $_ClientID
        $ReturnObject.UserId = $_UserId

        $UserPasswordCredential = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential]::new($_UserId, $_Password)

        Try
        {
            # Acquire Token
            $this.authContext | ConvertTo-Json | Log-AadSupportRunspace
            $request = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($this.authContext, $_ResourceId, $_ClientID, $UserPasswordCredential)
            $result = $request.GetAwaiter().GetResult()

            # Get Return Result Ready
            $ReturnObject.AccessToken = $result.AccessToken
            $ReturnObject.Authority = $result.Authority
            $ReturnObject.IdToken = $result.IdToken
            $ReturnObject.TenantId = $result.TenantId
            $ReturnObject.ExpiresOn = $result.ExpiresOn.ToString()
            $ReturnObject.DisplayableId = $result.UserInfo.DisplayableId
            $ReturnObject.UniqueId = $result.UserInfo.UniqueId

        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            $ReturnObject.Error = $true
            $ReturnObject.ErrorDetails = $_
        }
    
        #Return the authentication token
        return ($ReturnObject | ConvertTo-Json)
    }


    # ----------------------------------------------------------------------------
    # AcquireToken - Acquire Token Silently
    [string]AcquireSilentToken([string]$_ResourceId, [string]$_ClientID, [string]$_UserId)
    {
        $ReturnObject = @{}
        $ReturnObject.Resource = $_ResourceId
        $ReturnObject.ClientID = $_ClientID
        $ReturnObject.UserId = $_UserId
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

        # Set UserIdentifier
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
    

        Write-Verbose "Attempting authentication"
        try {

            $request = $this.authContext.AcquireTokenSilentAsync($_ResourceId, $_ClientID, $UserIdentifier)
            $result = $request.GetAwaiter().GetResult()
            $ReturnObject.AccessToken = $result.AccessToken
            $ReturnObject.Authority = $result.Authority
            $ReturnObject.IdToken = $result.IdToken
            $ReturnObject.TenantId = $result.TenantId
            $ReturnObject.ExpiresOn = $result.ExpiresOn.ToString()
            $ReturnObject.DisplayableId = $result.UserInfo.DisplayableId
            $ReturnObject.UniqueId = $result.UserInfo.UniqueId
          

        }
        Catch  #[System.Management.Automation.MethodInvocationException]
        {
            if($this.authContext.TokenCache.Count -gt 0)
            {
                "Cache is NOT empty. Silent failed probably because of different ClientId or UserId specified!" | Log-AadSupportRunspace
            }
            $ReturnObject.Error = $true
            $ReturnObject.ErrorDetails = $_
        }

        #Return the authentication token
        return ($ReturnObject | ConvertTo-Json)
    }

}

<# ##################################################
AAD SUPPORT FACING FUNCTIONS TO GET TOKEN
#################################################### #>

<#
## USER DELEGATED FLOW

   Get-AadSupportTokenForUser -Authority "https://login.microsoftonline.com/williamfiddes.onmicrosoft.com" 
    -ClientId "83258bc7-b7fd-4627-ae9b-e3bd5d550572" 
    -ResourceId "https://graph.microsoft.com" 
    -RedirectURI "https://login.microsoftonline.com/common/oauth2/nativeclient"

#>
function Get-AadSupportTokenForUser
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param
    (
        [string]$Authority,
        [string]$ResourceId,
        [string]$ClientId,
        [string]$RedirectURI,
        [string]$PromptBehavior,
        [string]$UserId,
        [string]$ExtraQueryParameters =""
    )

    "STARTING::Get-AadSupportTokenForUser" | Log-AadSupportRunspace
    "Authority::$Authority" | Log-AadSupportRunspace
    "ResourceId::$ResourceId" | Log-AadSupportRunspace
    "ClientId::$ClientId" | Log-AadSupportRunspace
    "RedirectURI::$RedirectURI" | Log-AadSupportRunspace
    "PromptBehavior::$PromptBehavior" | Log-AadSupportRunspace
    "UserId::$UserId" | Log-AadSupportRunspace
    "ExtraQueryParameters::$ExtraQueryParameters" | Log-AadSupportRunspace

    $context = GetOrBuildAuthenticationContext -Authority $Authority

    $AuthenticationResult = ""
    try {
        if($PromptBehavior -ne "Always")
        {
            $AuthenticationResult = $context.AcquireSilentToken($ResourceId,$ClientId,$UserId)  | ConvertFrom-Json
            $AuthenticationResult | ConvertTo-Json | Log-AadSupportRunspace
        }

        if($AuthenticationResult.Error -or $PromptBehavior -eq "Always") {
            $AuthenticationResult = $context.AcquireToken($ResourceId,$ClientId,$RedirectURI,$PromptBehavior,$UserId, $ExtraQueryParameters ) | ConvertFrom-Json
            $AuthenticationResult | ConvertTo-Json | Log-AadSupportRunspace
        }

        HandleAuthenticationResult -Authority $Authority -AuthenticationResult $AuthenticationResult
    }
    catch {
        try {
            $AuthenticationResult = $context.AcquireToken($ResourceId,$ClientId,$RedirectURI,$PromptBehavior,$UserId, $ExtraQueryParameters ) | ConvertFrom-Json
            $AuthenticationResult | ConvertTo-Json | Log-AadSupportRunspace
        }
        catch {
            return @{
                Error = $true
                ErrorDetails = $_
            }
        }
    }

    return $AuthenticationResult
}


<#
## ROPC/WIA (NON-INTERACTIVE) FLOW
#>
function Get-AadSupportTokenForUserWithPassword
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param
    (
        [string]$Authority,
        [string]$ResourceId,
        [string]$ClientId,
        [string]$UserId,
        [SecureString]$Password
    )

    "STARTING::Get-AadSupportTokenForUserWithPassword" | Log-AadSupportRunspace
    "Authority::$Authority" | Log-AadSupportRunspace
    "ResourceId::$ResourceId" | Log-AadSupportRunspace
    "ClientId::$ClientId" | Log-AadSupportRunspace
    "UserId::$UserId" | Log-AadSupportRunspace

    [AadContext]$context = GetOrBuildAuthenticationContext -Authority $Authority

    try {
        $AuthenticationResult = $context.AcquireTokenUsingUsernameAndPassword($ResourceId,$ClientId, $UserId, $Password) | ConvertFrom-Json
        $AuthenticationResult | ConvertTo-Json | Log-AadSupportRunspace

        HandleAuthenticationResult -Authority $Authority -AuthenticationResult $AuthenticationResult

        return $AuthenticationResult
    }
    catch {
        return @{
            Error = $true
            ErrorDetails = $_
        }
    }
}


<#
## CLIENT CREDENTIAL
#>
function Get-AadSupportTokenForClient
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param
    (
        [string]$Authority,
        [string]$ResourceId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $context = GetOrBuildAuthenticationContext -Authority $Authority
    $AuthenticationResult = ""
    try {
        
        $AuthenticationResult = $context.AcquireToken($ResourceId,$ClientId,$ClientSecret)  | ConvertFrom-Json
       
    }
    catch {
        return @{
            Error = $true
            ErrorDetails = $_
        }
    }

    return $AuthenticationResult
}

<### HELPER FUNCTIONS ###>

function GetOrBuildAuthenticationContext
{
    Param($Authority)

    if(!$Global:AadSupportAuthenticationContext)
    {
        "GetOrBuildAuthenticationContext::Creating Authentication Context Hashtable" | Log-AadSupportRunspace
        $Global:AadSupportAuthenticationContext = [hashtable]::new()
    }

    if(!$Global:AadSupportAuthenticationContext[$Authority])
    {
        "GetOrBuildAuthenticationContext::Creating Authentication Context for '$Authority'" | Log-AadSupportRunspace
        $Global:AadSupportAuthenticationContext[$Authority] = [AadContext]::new($Authority)
    }

    "GetOrBuildAuthenticationContext::Grabbed Authentication Context for '$Authority'" | Log-AadSupportRunspace
    $Global:AadSupportAuthenticationContext[$Authority] | ConvertTo-Json | Log-AadSupportRunspace
    return [AadContext]$Global:AadSupportAuthenticationContext[$Authority]
}

function HandleAuthenticationResult
{
    Param(
        $Authority,
        $AuthenticationResult
    )

    $Global:AadSupportAuthenticationContext[$AuthenticationResult.Authority] = $Global:AadSupportAuthenticationContext[$Authority]

    #$index = $Global:AadSupportAuthenticationContext.Keys.IndexOf($Authority)
    #$Global:AadSupportAuthenticationContext[$index] = $AuthenticationResult.Authority
}