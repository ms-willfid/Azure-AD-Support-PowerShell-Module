# AadSupport Authentication defaults
function New-AadSupportSession
{
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

        Common = @{
            AadInstance = "https://login.microsoftonline.com"
            TenantId = "common"
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

        CacheObject1 = $null
        CacheObject2 = $null

        AdalContext = @{}
    }
}

New-AadSupportSession

Export-ModuleMember -Function Connect-AadSupport
Export-ModuleMember -Function ConvertFrom-AadJwtToken
Export-ModuleMember -Function ConvertFrom-AadJwtTime
Export-ModuleMember -Function ConvertFrom-AadThumbprintToBase64String
Export-ModuleMember -Function ConvertFrom-AadBase64StringToThumbprint
Export-ModuleMember -Function ConvertFrom-AadBase64Certificate
Export-ModuleMember -Function Get-AadTokenUsingAdal
Export-ModuleMember -Function Get-AadToken
Export-ModuleMember -Function Get-AadAdminRolesByObject
Export-ModuleMember -Function Get-AadApplication
Export-ModuleMember -Function Get-AadAzureRoleAssignments
Export-ModuleMember -Function Get-AadConsentedPermissions
Export-ModuleMember -Function Get-AadDiscoveryKeys
Export-ModuleMember -Function Get-AadKeyVaultAccessByObject
Export-ModuleMember -Function Get-AadServicePrincipal
Export-ModuleMember -Function Get-AadServicePrincipalAdmins
Export-ModuleMember -Function Get-AadServicePrincipalAccess
Export-ModuleMember -Function Get-AadAppRolesByObject
Export-ModuleMember -Function Get-AadDateTime
Export-ModuleMember -Function Get-AadTenantAdmins
Export-ModuleMember -Function Get-AadObjectCount
Export-ModuleMember -Function Get-AadUserAccess
Export-ModuleMember -Function Get-AadUserRealm
Export-ModuleMember -Function Invoke-AadProtectedApi
Export-ModuleMember -Function Set-AadConsent
Export-ModuleMember -Function Import-AadAzureRoleAssignments
Export-ModuleMember -Function Export-AadAzureRoleAssignments
Export-ModuleMember -Function Update-AadSupport