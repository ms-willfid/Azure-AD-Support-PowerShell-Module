<#
.SYNOPSIS
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

.DESCRIPTION
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

Example 1: Log in with your admin account...
Connect-AadSupport

Example 2: Log in with a new session...
Connect-AadSupport -NewSession

Example 3: Log in to a specific tenant...
Connect-AadSupport -TenantId contoso.onmicrosoft.com

Example 4: Log in to a specific instance...
Connect-AadSupport -AzureEnvironmentName AzureCloud
Connect-AadSupport -AzureEnvironmentName AzureGermanyCloud
Connect-AadSupport -AzureEnvironmentName AzureChinaCloud
Connect-AadSupport -AzureEnvironmentName AzureUSGovernment

.PARAMETER TenantId
Provide the Tenant ID you want to authenticate to.

.PARAMETER AzureEnvironmentName
Specifies the name of the Azure environment. The acceptable values for this parameter are:

        - AzureCloud
        - AzureChinaCloud
        - AzureUSGovernment
        - AzureGermanyCloud

        The default value is AzureCloud.

.PARAMETER LogLevel
Specifies the log level. The accdeptable values for this parameter are:

        - Info
        - Error
        - Warning
        - None

.PARAMETER LogPath
The path where the log file for this PowerShell session is written to. Provide a value here if you need to
deviate from the default PowerShell log file location.

.PARAMETER NewSession
By default, when calling Connect-AadSupport will use a cached access token. To sign-in again, Use this switch.


.NOTES
General notes
#>

function Connect-AadSupport
{
    [CmdletBinding()]
    param (
        $TenantId = "Common",

        [ValidateSet("AzureCloud","AzureGermanyCloud","AzureUSGovernment","AzureChinaCloud")]
        $AzureEnvironmentName = "AzureCloud",

        $LogLevel = "Info",
        $LogPath = "C:\AadExtensionLogs",

        [switch]
        $NewSession = $false
    )

    switch($AzureEnvironmentName)
    {
        "AzureCloud" 
        {
            $Global:AadSupport.Session.AadInstance = "https://login.microsoftonline.com"
            $Global:AadSupport.Resources.AadGraph = "https://graph.windows.net"
            $Global:AadSupport.Resources.MsGraph = "https://graph.microsoft.com"
            $Global:AadSupport.Resources.AzureRmApi = "https://management.azure.com"
            $Global:AadSupport.Resources.AzureServiceApi = "https://management.core.windows.net"
            $Global:AadSupport.Resources.KeyVault = "https://vault.azure.net"
        }

        "AzureChinaCloud"
        {
            $Global:AadSupport.Session.AadInstance = "https://login.chinacloudapi.cn" #https://login.partner.microsoftonline.cn
            $Global:AadSupport.Resources.AadGraph = "https://graph.chinacloudapi.cn"
            $Global:AadSupport.Resources.MsGraph = "https://microsoftgraph.chinacloudapi.cn"
            $Global:AadSupport.Resources.AzureRmApi = "https://management.chinacloudapi.cn"
            $Global:AadSupport.Resources.AzureServiceApi = "https://management.core.chinacloudapi.cn"
            $Global:AadSupport.Resources.KeyVault = "https://vault.azure.cn"
        }

        "AzureUSGovernment"
        {
            $Global:AadSupport.Session.AadInstance = "https://login.microsoftonline.us"
            $Global:AadSupport.Resources.AadGraph = "https://graph.windows.net"
            $Global:AadSupport.Resources.MsGraph = "https://graph.microsoft.us" #DOD https://dod-graph.microsoft.us
            $Global:AadSupport.Resources.AzureRmApi = "https://management.usgovcloudapi.net/"
            $Global:AadSupport.Resources.AzureServiceApi = "https://management.core.usgovcloudapi.net/"
            $Global:AadSupport.Resources.KeyVault = "https://vault.usgovcloudapi.net"
        }

        "AzureGermanyCloud"
        {
            $Global:AadSupport.Session.AadInstance = "https://login.microsoftonline.de"
            $Global:AadSupport.Resources.AadGraph = "https://graph.cloudapi.de/"
            $Global:AadSupport.Resources.MsGraph = "https://graph.microsoft.de"
            $Global:AadSupport.Resources.AzureRmApi = "https://management.microsoftazure.de/"
            $Global:AadSupport.Resources.AzureServiceApi = "https://management.core.cloudapi.de/"
            $Global:AadSupport.Resources.KeyVault = "https://vault.microsoftazure.de"
        }
    }

    if($NewSession)
    {
        New-AadSupportSession
    }

    # Connect to Azure AD PowerShell

        try {

            $AzureContext = Get-AzContext

            if(-not $Global:AadSupport.Session.Active)
            {
                $Prompt = "Always"
                Write-Host ""
                Write-Host "Connecting to Azure AD PowerShell (Connect-AzureAD)"
                Write-Host "and Connecting to Azure PowerShell (Connect-AzAccount)"
                Write-Host ""
            }
            else {
                $Prompt = "Auto"
            }

            # Get Current Session Info
            $AccountId = $Global:AadSupport.Session.AccountId
            $TenantDomain = $Global:AadSupport.Session.TenantDomain

            # Get Token for AAD Graph to be used for Azure AD PowerShell
            $token = Get-AadTokenUsingAdal `
              -ResourceId $Global:AadSupport.Resources.AadGraph `
              -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
              -Redirect $Global:AadSupport.Clients.AzureAdPowershell.RedirectUri `
              -Tenant $TenantDomain `
              -UserId $AccountId `
              -Prompt $Prompt `
              -SkipServicePrincipalSearch `
              -HideOutput
            
            $AadAccessToken = $token.AccessToken

            $AccountId = $token.IdTokenClaims.upn
            $TenantId = $token.IdTokenClaims.tid

            $Session = Connect-AzureAd `
            -TenantId $TenantId `
            -AzureEnvironmentName $AzureEnvironmentName `
            -LogLevel $LogLevel `
            -LogFilePath $LogPath `
            -AadAccessToken $AadAccessToken `
            -AccountId $AccountId

            # Determine if we need to reset Azure Context
            $TenantDomain = $Session.TenantDomain
            $Global:AadSupport.Session.TenantDomain = $TenantDomain

            if($AzureContext `
            -and $Azure.Context.Tenants -contains -not "$($Session.TenantId)" `
            -and $Azure.Context.Id -ne "$($Session.Account)" )
            {
                Write-Verbose "Running 'Disconnect-AzAccount'"
                Disconnect-AzAccount | Out-Null
            }

            # Get Token for Azure to be used for Azure PowerShell
            $token = Get-AadTokenUsingAdal `
            -ResourceId $Global:AadSupport.Resources.AzureRmApi `
            -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
            -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
            -UserId $AccountId `
            -Tenant $TenantId `
            -Prompt Never `
            -SkipServicePrincipalSearch `
            -HideOutput

            $AzureRmApiAccessToken = $token.AccessToken

            $Global:AadSupport.Session.AccountId = $Session.Account
            $Global:AadSupport.Session.TenantId = $Session.TenantId

            $AzureSession = Connect-AzAccount `
            -AccessToken $AzureRmApiAccessToken `
            -GraphAccessToken $AadAccessToken `
            -AccountId $Global:AadSupport.Session.AccountId `
            -Tenant $TenantId
            
            $Global:AadSupport.Session.Active = $true
        }
        catch {
            throw $_
        }

        
    
}
