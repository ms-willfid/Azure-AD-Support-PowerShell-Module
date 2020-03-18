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
        
        $ReturnObject = @{}
        $ReturnObject.Resource = $_ResourceId
        $ReturnObject.ClientID = $_ClientID
        $ReturnObject.UserId = $_UserId

        $UserPasswordCredential = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential]::new($_UserId, $_Password)

        Try
        {
            # Acquire Token
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
            $ReturnObject.Error = $true
            $ReturnObject.ErrorDetails = $_
        }

        #Return the authentication token
        return ($ReturnObject | ConvertTo-Json)
    }

}


<#
## USER DELEGATED FLOW
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

    if(!$Global:AadSupportAuthenticationContext)
    {
        $Global:AadSupportAuthenticationContext = [AadContext]::new($Authority)
    }

    $AuthenticationResult = ""
    try {
        if($PromptBehavior -ne "Always")
        {
            $AuthenticationResult = $Global:AadSupportAuthenticationContext.AcquireSilentToken($ResourceId,$ClientId,$UserId)  | ConvertFrom-Json
        
        }

        if($AuthenticationResult.Error -or $PromptBehavior -eq "Always") {
            $AuthenticationResult = $Global:AadSupportAuthenticationContext.AcquireToken($ResourceId,$ClientId,$RedirectURI,$PromptBehavior,$UserId, $ExtraQueryParameters ) | ConvertFrom-Json
        }
    }
    catch {
        try {
            $AuthenticationResult = $Global:AadSupportAuthenticationContext.AcquireToken($ResourceId,$ClientId,$RedirectURI,$PromptBehavior,$UserId, $ExtraQueryParameters ) | ConvertFrom-Json
            
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

    if(!$Global:AadSupportAuthenticationContext)
    {
        $Global:AadSupportAuthenticationContext = [AadContext]::new($Authority)
    }

    try {
        return $Global:AadSupportAuthenticationContext.AcquireTokenUsingUsernameAndPassword($ResourceId,$ClientId, $UserId, $Password) | ConvertFrom-Json

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

    if(!$Global:AadSupportAuthenticationContext)
    {
        $Global:AadSupportAuthenticationContext = [AadContext]::new($Authority)
    }

    $AuthenticationResult = ""
    try {
        
        $AuthenticationResult = $Global:AadSupportAuthenticationContext.AcquireToken($ResourceId,$ClientId,$ClientSecret)  | ConvertFrom-Json
       
    }
    catch {
        return @{
            Error = $true
            ErrorDetails = $_
        }
    }

    return $AuthenticationResult
}
<#
Get-AadSupportTokenForUser -Authority "https://login.microsoftonline.com/williamfiddes.onmicrosoft.com" -ClientId "83258bc7-b7fd-4627-ae9b-e3bd5d550572" -ResourceId "https://graph.microsoft.com" -RedirectURI "https://login.microsoftonline.com/common/oauth2/nativeclient"
#>
