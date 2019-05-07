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
            $global:AadSupportSession = Connect-AzureAd `
                -TenantId $TenantId `
                -AzureEnvironmentName $AzureEnvironmentName `
                -verbose `
                -LogLevel $LogLevel `
                -LogFilePath $LogPath 
        }
        catch {
            throw $_
        }
    }
}

<#
PARAMETERS
    -AadAccessToken <String>
        Specifies a Azure Active Directory Graph access token.

    -AccountId <String>
        Specifies the ID of an account. You must specify the UPN of the user when authenticating with a user access
        token.

    -ApplicationId <String>
        Specifies the application ID of the service principal.

    -AzureEnvironmentName <EnvironmentName>
        Specifies the name of the Azure environment. The acceptable values for this parameter are:

        - AzureCloud
        - AzureChinaCloud
        - AzureUSGovernment
        - AzureGermanyCloud

        The default value is AzureCloud.

    -CertificateThumbprint <String>
        Specifies the certificate thumbprint of a digital public key X.509 certificate of a user account that has
        permission to perform this action.

    -Credential <PSCredential>
        Specifies a PSCredential object. For more information about the PSCredential object, type Get-Help
        Get-Credential.

        The PSCredential object provides the user ID and password for organizational ID credentials.

    -InformationAction <ActionPreference>
        Specifies how this cmdlet responds to an information event. The acceptable values for this parameter are:

        - Continue
        - Ignore
        - Inquire
        - SilentlyContinue
        - Stop
        - Suspend

    -InformationVariable <String>
        Specifies a variable in which to store an information event message.

    -LogLevel <LogLevel>
        Specifies the log level. The accdeptable values for this parameter are:

        - Info
        - Error
        - Warning
        - None

        The default value is Info.

    -MsAccessToken <String>
        Specifies a Microsoft Graph access token.

    -TenantId <String>
        Specifies the ID of a tenant.

        If you do not specify this parameter, the account is authenticated with the home tenant.

        You must specify the TenantId parameter to authenticate as a service principal or when using Microsoft account.

    -Confirm [<SwitchParameter>]
        Prompts you for confirmation before running the cmdlet.

    -WhatIf [<SwitchParameter>]
        Shows what would happen if the cmdlet runs. The cmdlet is not run.

    -LogFilePath <String>
        The path where the log file for this PowerShell session is written to. Provide a value here if you need to
        deviate from the default PowerShell log file location.
#>