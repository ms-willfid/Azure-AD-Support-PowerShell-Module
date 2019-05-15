<#
.SYNOPSIS
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

.DESCRIPTION
Connect to the Azure AD Support PowerShell module. This will use the same sign-in session to access different Microsoft resources.

.PARAMETER TenantId
Provide the Tenant ID you want to authenticate to.

.PARAMETER AzureEnvironmentName
Provide the Azure AD Instance you want to connect to.

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

.EXAMPLE
Example 1: Log in with your admin account...
Connect-AadSupport

.NOTES
General notes
#>

function Connect-AadSupport
{
    param (
        $TenantId = "Common",
        $AzureEnvironmentName = "AzureCloud",
        $LogLevel = "Info",
        $LogPath = "C:\AadExtensionLogs",

        [switch]
        $NewSession = $false
    )
    
    if ($NewSession)
    {
        $global:AadSupportSession = ""
    }

    

    # Connect to Azure AD PowerShell
    if (-not $global:AadSupportSession) {
        try {
            $result = Get-AadTokenUsingAdal -ClientId $Global:AadSupportAppId -Redirect $Global:AadSupportRedirectUri -ResourceId $Global:ResourceAadGraph -Tenant $TenantId
            $AccessToken = $result.AccessToken
            $IdToken = $result.IdToken
            $upn = ($IdToken | ConvertFrom-AadJwtToken).upn
            $global:AadSupportSession = Connect-AzureAd `
                -TenantId $TenantId `
                -AzureEnvironmentName $AzureEnvironmentName `
                -verbose `
                -LogLevel $LogLevel `
                -LogFilePath $LogPath `
                -AadAccessToken $AccessToken `
                -AccountId $upn
        }
        catch {
            throw $_
        }
    }
}
