---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadOpenIdConnectConfiguration

## SYNOPSIS
Gets the Azure AD Open Id Connect Configuration

## SYNTAX

### Default (Default)
```
Get-AadOpenIdConnectConfiguration [-ApplicationId <String>] [<CommonParameters>]
```

### SetTenantAndInstance
```
Get-AadOpenIdConnectConfiguration [-Tenant <String>] [-AadInstance <String>] [-ApplicationId <String>]
 [<CommonParameters>]
```

### SetIssuer
```
Get-AadOpenIdConnectConfiguration [-Issuer <String>] [-ApplicationId <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the Azure AD Open Id Connect Configuration

PS C:\\\>Get-AadOpenIdConnectConfiguration
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

## EXAMPLES

### EXAMPLE 1
```
Get-AadOpenIdConnectConfiguration
```

### EXAMPLE 2
```
Get-AadOpenIdConnectConfiguration -Tenant contoso.onmicrosoft.com -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53
```

### EXAMPLE 3
```
Get-AadOpenIdConnectConfiguration -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/"
```

## PARAMETERS

### -Tenant
Specify the tenant.
This would be required if getting specific information about an app

```yaml
Type: String
Parameter Sets: SetTenantAndInstance
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AadInstance
Specify the Azure AD Instance i.e.
https://login.microsoftonline.com or https://login.microsoftonline.us

```yaml
Type: String
Parameter Sets: SetTenantAndInstance
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issuer
You can specify the full Issuer.
This would be required to correctly get Open Id Connect Configuration for Azure AD B2C

```yaml
Type: String
Parameter Sets: SetIssuer
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApplicationId
Specify the Application ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
