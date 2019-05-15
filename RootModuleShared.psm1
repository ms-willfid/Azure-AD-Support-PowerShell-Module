# AadSupport Authentication defaults
$Global:AadSupportAppId = "a57bfff5-9e23-439d-9993-48d76ba688ca"
$Global:AadSupportRedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"

$Global:ResourceAadGraph = "https://graph.windows.net"
$Global:ResourceMsGraph = "https://graph.microsoft.com"
$Global:ResourceAzure = "https://management.azure.com"


Export-ModuleMember -Function Connect-AadSupport
Export-ModuleMember -Function Get-AadTokenUsingAdal
Export-ModuleMember -Function Get-AadToken
Export-ModuleMember -Function Get-AadServicePrincipal
Export-ModuleMember -Function Get-AadServicePrincipalAdmins
Export-ModuleMember -Function Get-AadServicePrincipalAccess
Export-ModuleMember -Function ConvertFrom-AadJwtToken
Export-ModuleMember -Function Convert-AadJwtTime
Export-ModuleMember -Function Get-AadDateTime
Export-ModuleMember -Function Invoke-AadProtectedApi

Export-ModuleMember -Alias Get-AadSp
