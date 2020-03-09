<#
.SYNOPSIS
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

.DESCRIPTION
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

Example 1: Log in with your admin account...
Connect-AadSupport

Example 2: Log in to a specific tenant...
Connect-AadSupport -TenantId contoso.onmicrosoft.com

Example 3: Log in to a specific instance...
Connect-AadSupport -AzureEnvironmentName AzureCloud
Connect-AadSupport -AzureEnvironmentName AzureGermanyCloud
Connect-AadSupport -AzureEnvironmentName AzureChinaCloud
Connect-AadSupport -AzureEnvironmentName AzureUSGovernment

.PARAMETER TenantId
Provide the Tenant ID you want to authenticate to.

.PARAMETER AccountId
Provide the Account ID you want to authenticate with.

.PARAMETER AzureEnvironmentName
Specifies the name of the Azure environment. The acceptable values for this parameter are:

        - AzureCloud
        - AzureChinaCloud
        - AzureUSGovernment
        - AzureGermanyCloud

        The default value is AzureCloud.

.PARAMETER LogPath
The path where the log file for this PowerShell session is written to. Provide a value here if you need to
deviate from the default PowerShell log file location.

.NOTES
General notes
#>

function Connect-AadSupport
{
    [CmdletBinding()]
    param (
        $TenantId = "Common",
        $AccountId,
        $Password,

        [ValidateSet("AzureCloud","AzureGermanyCloud","AzureUSGovernment","AzureChinaCloud")]
        $AzureEnvironmentName = "AzureCloud",

        [Switch]$EnableLogging
    )

    # Parameter Validations

    if($EnableLogging)
    {
        $Global:AadSupport.Logging.Enabled = $true
    }
    else
    {
        $Global:AadSupport.Logging.Enabled = $false
    }

    if($LogPath)
    {
        $Global:AadSupport.Logging.Path = $LogPath
    }

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

    New-AadSupportSession

    Write-Host ""
    Write-Host "Connecting to Azure AD PowerShell (Connect-AzureAD)"
    Write-Host "and Connecting to Azure PowerShell (Connect-AzAccount)"
    Write-Host ""

    # Connect to Azure AD PowerShell
    # Get Current Session Info
    if(!$AccountId)
    {
        $AccountId = $Global:AadSupport.Session.AccountId
    }

    try {

        if(!$AccountId)
        {
            $Prompt = "Always"
        }
        else {
            $Prompt = "Auto"
        }

        

        # Get Token for AAD Graph to be used for Azure AD PowerShell
        $token = $null
        if($Password)
        {
            $token = Get-AadTokenUsingAdal `
            -ResourceId $Global:AadSupport.Resources.AadGraph `
            -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
            -Tenant $TenantId `
            -UserId $AccountId `
            -Password $Password `
            -UseResourceOwnerPasswordCredential `
            -SkipServicePrincipalSearch `
            -HideOutput
        }

        else 
        { 
            $token = Get-AadTokenUsingAdal `
                -ResourceId $Global:AadSupport.Resources.AadGraph `
                -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
                -Redirect $Global:AadSupport.Clients.AzureAdPowershell.RedirectUri `
                -Tenant $TenantId `
                -UserId $AccountId `
                -Prompt $Prompt `
                -SkipServicePrincipalSearch `
                -HideOutput
        }

        $Global:AadSupport.Session.AccountId = $token.DisplayableId
        $Global:AadSupport.Session.TenantId = $token.TenantId

        # Get Token for Azure to be used for Azure PowerShell
        $token = $null
        $token = Get-AadTokenUsingAdal `
        -ResourceId $Global:AadSupport.Resources.AzureRmApi `
        -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
        -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
        -UserId $Global:AadSupport.Session.AccountId `
        -Tenant $Global:AadSupport.Session.TenantId `
        -Prompt Never `
        -SkipServicePrincipalSearch `
        -HideOutput
        
        $Global:AadSupport.Session.Active = $true
    }
    catch {
        throw $_
    }

        
    
}


