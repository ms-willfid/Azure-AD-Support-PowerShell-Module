# AadSupport Authentication defaults
$Global:AadSupport = @{
    Path = $PSScriptRoot
    ClientId = "a57bfff5-9e23-439d-9993-48d76ba688ca"
    RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
    Session = @{
        AadInstance = $null
        TenantId = $null
        AccountId = $null
        Active = $false
    }

    Clients = @{
        AzureAdPowerShell = @{
            ClientId = "1b730954-1685-4b74-9bfd-dac224a7b894"
            RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
        }
        AzurePowerShell = @{
            ClientId = "1950a258-227b-4e31-a9cf-717495945fc2"
            RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
        }
    }

    Resources = @{
        AadGraph = "https://graph.windows.net"
        MsGraph = "https://graph.microsoft.com"
        AzureRmApi = "https://management.azure.com"
        AzureServiceApi = "https://management.core.windows.net"
        KeyVault = "https://vault.azure.net"
    }
}

Export-ModuleMember -Function Connect-AadSupport
Export-ModuleMember -Function ConvertFrom-AadJwtToken
Export-ModuleMember -Function Convert-AadJwtTime
Export-ModuleMember -Function Convert-AadThumbprintToBase64String
Export-ModuleMember -Function Convert-AadBase64StringToThumbprint
Export-ModuleMember -Function ConvertFrom-AadBase64Certificate
Export-ModuleMember -Function Get-AadTokenUsingAdal
Export-ModuleMember -Function Get-AadToken
Export-ModuleMember -Function Get-AadServicePrincipal
Export-ModuleMember -Function Get-AadServicePrincipalAdmins
Export-ModuleMember -Function Get-AadServicePrincipalAccess
Export-ModuleMember -Function Get-AadServicePrincipalAppRoles
Export-ModuleMember -Function Get-AadDateTime
Export-ModuleMember -Function Get-AadTenantAdmins
Export-ModuleMember -Function Invoke-AadProtectedApi
Export-ModuleMember -Function Set-AadConsent

Export-ModuleMember -Alias Get-AadSp
Export-ModuleMember -Alias Get-AadSpAdmins
Export-ModuleMember -Alias Get-AadSpAccess
Export-ModuleMember -Alias Get-AadSpAppRoles