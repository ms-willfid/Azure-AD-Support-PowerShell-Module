
<#
.SYNOPSIS
Gets the Azure AD Open Id Connect Configuration

.DESCRIPTION
Gets the Azure AD Open Id Connect Configuration

PS C:\>Get-AadOpenIdConnectConfiguration
Downloading configuration from 'https://login.microsoftonline.com/common/.well-known/openid-configuration'

token_endpoint                        : https://login.microsoftonline.com/common/oauth2/token
token_endpoint_auth_methods_supported : {client_secret_post, private_key_jwt, client_secret_basic}
jwks_uri                              : https://login.microsoftonline.com/common/discovery/keys
response_modes_supported              : {query, fragment, form_post}
subject_types_supported               : {pairwise}
id_token_signing_alg_values_supported : {RS256}
response_types_supported              : {code, id_token, code id_token, token id_token...}
scopes_supported                      : {openid}
issuer                                : https://sts.windows.net/{tenantid}/
microsoft_multi_refresh_token         : True
authorization_endpoint                : https://login.microsoftonline.com/common/oauth2/authorize
http_logout_supported                 : True
frontchannel_logout_supported         : True
end_session_endpoint                  : https://login.microsoftonline.com/common/oauth2/logout
claims_supported                      : {sub, iss, cloud_instance_name, cloud_instance_host_name...}
check_session_iframe                  : https://login.microsoftonline.com/common/oauth2/checksession
userinfo_endpoint                     : https://login.microsoftonline.com/common/openid/userinfo
tenant_region_scope                   :
cloud_instance_name                   : microsoftonline.com
cloud_graph_host_name                 : graph.windows.net
msgraph_host                          : graph.microsoft.com
rbac_url                              : https://pas.windows.net
ApplicationId                         :

.PARAMETER Tenant
Specify the tenant. This would be required if getting specific information about an app

.PARAMETER AadInstance
Specify the Azure AD Instance i.e. https://login.microsoftonline.com or https://login.microsoftonline.us

.PARAMETER Issuer
You can specify the full Issuer. This would be required to correctly get Open Id Connect Configuration for Azure AD B2C

.PARAMETER ApplicationId
Specify the Application ID

.EXAMPLE
Get-AadOpenIdConnectConfiguration 

.EXAMPLE
Get-AadOpenIdConnectConfiguration -Tenant contoso.onmicrosoft.com -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53

.EXAMPLE
Get-AadOpenIdConnectConfiguration -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/"

.NOTES
General notes
#>
function Get-AadOpenIdConnectConfiguration
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName = 'SetTenantAndInstance')]
        [string]$Tenant, 

        [Parameter(ParameterSetName = 'SetTenantAndInstance')]
        [string]$AadInstance,

        [Parameter(ParameterSetName = 'SetIssuer')]
        [string]$Issuer,

        [string]$ApplicationId
    ) 

    # Populate Tenant info
    if($Global:AadSupport.Session.Active -and -not $Tenant)
    {
        $Tenant = $Global:AadSupport.Session.TenantId
    }

    if(-not $Tenant)
    {
        $Tenant = "common"
    }

    # Populate AadInstance info
    if($Global:AadSupport.Session -and -not $AadInstance)
    {
        $AadInstance = $Global:AadSupport.Session.AadInstance
    }

    if(-not $AadInstance)
    {
        $AadInstance = "https://login.microsoftonline.com"
    }

    # Set the Open ID Connect Configuration Endpoint
    if(!$Issuer)
    {
        $Issuer = "$AadInstance/$Tenant"
    }
    elseif($Issuer.LastIndexOf("/") -eq $Issuer.Length-1)
    {
        $Issuer = $Issuer.Substring(0,$Issuer.Length-1)
    }

    $Url = $Issuer

    if(!$Issuer.Contains("/.well-known/openid-configuration"))
    {
        $Url += "/.well-known/openid-configuration"
    }
    

    if($ApplicationId -and !$Issuer.Contains("appid="))
    {
        $Url += "?appid=$ApplicationId"
    }
    elseif($ApplicationId -and $Issuer.Contains("appid="))
    {
        Write-Warning "Using Application ID provided in Issuer"
    }
    elseif($Issuer.Contains("appid="))
    {
        $ApplicationId = ($Issuer.Split("?")[1].Split("&") | where {$_ -match 'appid'}).Split("=")[1]
    }

    # Get the Discovery Keys
    Write-Host "Downloading configuration from '$Url'"
    $Configuration = (ConvertFrom-Json (Invoke-WebRequest $Url).Content)
    $Configuration | Add-Member -Type NoteProperty -Name "ApplicationId" -Value $ApplicationId
    

    return $Configuration
}
 
function Test-Get-AadOpenIdConnectConfiguration
{
    # Provide no issuer
    Get-AadOpenIdConnectConfiguration 

    # Provide a tenant
    Get-AadOpenIdConnectConfiguration -Tenant "williamfiddesb2c.onmicrosoft.com"

    # Provide a instance
    Get-AadOpenIdConnectConfiguration -AadInstance "https://login.microsoftonline.us"

    # Provide a AAD Issuer
    Get-AadOpenIdConnectConfiguration -Issuer "https://login.microsoftonline.com/williamfiddes.onmicrosoft.com"

    # Provide a B2C Issuer
    Get-AadOpenIdConnectConfiguration -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/.well-known/openid-configuration"
    
    # Provide a Issuer with a appid
    Get-AadOpenIdConnectConfiguration -Issuer https://login.microsoftonline.com/williamfiddes.onmicrosoft.com/.well-known/openid-configuration?appid=bcdeb54f-733b-4657-8948-0f39934c2a53

    # Provide a appid
    Get-AadOpenIdConnectConfiguration -Tenant "williamfiddes.onmicrosoft.com" -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53

    # Show Warning
    Get-AadOpenIdConnectConfiguration -Issuer https://login.microsoftonline.com/williamfiddes.onmicrosoft.com/.well-known/openid-configuration?appid=bcdeb54f-733b-4657-8948-0f39934c2a53 -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53
}