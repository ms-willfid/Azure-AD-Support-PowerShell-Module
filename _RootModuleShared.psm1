Export-ModuleMember -Function Add-AadConsent
Export-ModuleMember -Function Connect-AadSupport
Export-ModuleMember -Function ConvertFrom-AadJwtToken
Export-ModuleMember -Function ConvertFrom-AadJwtTime
Export-ModuleMember -Function ConvertFrom-AadThumbprintToBase64String
Export-ModuleMember -Function ConvertFrom-AadBase64String
Export-ModuleMember -Function ConvertFrom-AadBase64StringToThumbprint
Export-ModuleMember -Function ConvertFrom-AadBase64Certificate
<<<<<<< HEAD
Export-ModuleMember -Function ConvertFrom-AadImmutableId
=======
>>>>>>> df812b2feffde2d1fcf1d9bbbe7f62f63115b552
Export-ModuleMember -Function ConvertTo-AadBase64EncodedString
Export-ModuleMember -Function Get-AadAppPermissionInfo
Export-ModuleMember -Function Get-AadAdminRolesByObject
Export-ModuleMember -Function Get-AadApplication
Export-ModuleMember -Function Get-AadAppRolesByObject
Export-ModuleMember -Function Get-AadAzureRoleAssignments
Export-ModuleMember -Function Get-AadConsent
Export-ModuleMember -Function Get-AadDateTime
Export-ModuleMember -Function Get-AadDiscoveryKeys
Export-ModuleMember -Function Get-AadKeyVaultAccessByObject
Export-ModuleMember -Function Get-AadObjectCount
Export-ModuleMember -Function Get-AadOpenIdConnectConfiguration
Export-ModuleMember -Function Get-AadReportCredentialsExpiringSoon
Export-ModuleMember -Function Get-AadReportMfaEnrolled
Export-ModuleMember -Function Get-AadReportMfaEnabled
Export-ModuleMember -Function Get-AadReportMfaNotEnrolled
Export-ModuleMember -Function Get-AadServicePrincipal
Export-ModuleMember -Function Get-AadServicePrincipalAdmins
Export-ModuleMember -Function Get-AadServicePrincipalAccess
Export-ModuleMember -Function Get-AadTenantAdmins
Export-ModuleMember -Function Get-AadTokenUsingAdal
Export-ModuleMember -Function Get-AadToken
Export-ModuleMember -Function Get-AadUserAccess
#Export-ModuleMember -Function Get-AadUserInfo
Export-ModuleMember -Function Get-AadUserRealm
Export-ModuleMember -Function Invoke-AadProtectedApi
Export-ModuleMember -Function New-AadClientAssertion
Export-ModuleMember -Function New-AadApplicationCertificate
Export-ModuleMember -Function Set-AadConsent
Export-ModuleMember -Function Revoke-AadConsent
Export-ModuleMember -Function Import-AadAzureRoleAssignments
Export-ModuleMember -Function Export-AadAzureRoleAssignments
Export-ModuleMember -Function Update-AadSupport

Export-ModuleMember -Function Test-AadToken
New-Alias -Name "Validate-AadToken" Test-AadToken
Export-ModuleMember -Alias Validate-AadToken
