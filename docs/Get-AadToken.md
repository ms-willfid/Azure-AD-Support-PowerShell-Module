---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadToken

## SYNOPSIS
Get Access Token from Azure AD token endpoint.

## SYNTAX

### All (Default)
```
Get-AadToken [-ClientId] <String> [-ClientSecret <String>] [-ResourceId <String>] [-Scopes <String>]
 [-Redirect <String>] [-Instance <String>] [-UseV2] [-GrantType <String>] [-Code <String>]
 [-Assertion <String>] [-ClientAssertionType <String>] [-ClientAssertion <String>]
 [-RequestedTokenUse <String>] [-RequestedTokenType <String>] [<CommonParameters>]
```

### UseResourceOwner
```
Get-AadToken [-ClientId] <String> [-UseResourceOwner] -Username <String> -Password <String>
 [-ClientSecret <String>] [-ResourceId <String>] [-Tenant <String>] [-Scopes <String>] [-Redirect <String>]
 [-Instance <String>] [-UseV2] [-GrantType <String>] [-Code <String>] [-Assertion <String>]
 [-ClientAssertionType <String>] [-ClientAssertion <String>] [-RequestedTokenUse <String>]
 [-RequestedTokenType <String>] [<CommonParameters>]
```

### UseClientCredential
```
Get-AadToken [-ClientId] <String> [-UseClientCredential] [-ClientSecret <String>] [-ResourceId <String>]
 -Tenant <String> [-Scopes <String>] [-Redirect <String>] [-Instance <String>] [-UseV2] [-GrantType <String>]
 [-Code <String>] [-Assertion <String>] [-ClientAssertionType <String>] [-ClientAssertion <String>]
 [-RequestedTokenUse <String>] [-RequestedTokenType <String>] [<CommonParameters>]
```

### UseRefreshToken
```
Get-AadToken [-ClientId] <String> [-UseRefreshToken] [-ClientSecret <String>] -RefreshToken <String>
 [-ResourceId <String>] [-Tenant <String>] [-Scopes <String>] [-Redirect <String>] [-Instance <String>]
 [-UseV2] [-GrantType <String>] [-Code <String>] [-Assertion <String>] [-ClientAssertionType <String>]
 [-ClientAssertion <String>] [-RequestedTokenUse <String>] [-RequestedTokenType <String>] [<CommonParameters>]
```

## DESCRIPTION
Get Access Token from Azure AD token endpoint.

## EXAMPLES

### EXAMPLE 1
```
Use Resource Owner Password Credential grant flow
```

Get-AadToken -UseResourceOwner -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -Redirect "https://login.microsoftonline.com/common/oauth2/nativeclient" -Username john@contoso.com -Password P@$$w0rd!

To get client only access token
Get-AadToken -UseClientCredential -ResourceId "https://graph.microsoft.com" -ClientId 5567ba8a-e608-4219-97d8-3d3ea63718e7 -ClientSecret "98iwjdc-098343js="

## PARAMETERS

### -ClientId
Provide Client ID or App ID required to get a access token

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseResourceOwner
Enable this switch if you want to use the Resource Owner Password Credential grant flow.

```yaml
Type: SwitchParameter
Parameter Sets: UseResourceOwner
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseClientCredential
Enable this switch if you want to use the Client Credential grant flow.

```yaml
Type: SwitchParameter
Parameter Sets: UseClientCredential
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseRefreshToken
Enable this switch if you want to use the Refresh Token grant flow.

```yaml
Type: SwitchParameter
Parameter Sets: UseRefreshToken
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Provide username if using Resource Owner Password grant flow.

```yaml
Type: String
Parameter Sets: UseResourceOwner
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Provide Password of resource owner if using Resource Owner Password Credential grant flow.

```yaml
Type: String
Parameter Sets: UseResourceOwner
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Provide Client Secret if this is a Web App client.

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

### -RefreshToken
{{ Fill RefreshToken Description }}

```yaml
Type: String
Parameter Sets: UseRefreshToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId
Provide App URI ID or Service Principal Name you want to get an access token for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://graph.microsoft.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant
Provide Tenant ID you are authenticating to.

```yaml
Type: String
Parameter Sets: UseResourceOwner, UseRefreshToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: UseClientCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
Provide Scopes for the request.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Openid email profile offline_access https://graph.microsoft.com/.default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Redirect
Provide Redirect URI or Redirect URL.

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

### -Instance
Provide Azure AD Instance you are connecting to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://login.microsoftonline.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseV2
By default, Azure AD V1 authentication endpoints will be used.
Use this if you want to use the V2 Authentication endpoints.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GrantType
Specify the 'grant_type' you want to use.
 - password
 - client_credentials
 - refresh_token
 - authorization_code
 - urn:ietf:params:oauth:grant-type:jwt-bearer
 - urn:ietf:params:oauth:grant-type:saml1_1-bearer
 - urn:ietf:params:oauth:grant-type:saml2-bearer

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

### -Code
Specify the 'code' for authorization code flow

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

### -Assertion
Specify the 'assertion' you want to use for user assertion

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

### -ClientAssertionType
Specify the 'client_assertion_type' you want to use.

Available options...
 - urn:ietf:params:oauth:client-assertion-type:jwt-bearer

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

### -ClientAssertion
Specify the 'client_assertion' you want to use.
This is used for Certificate authentication where the client assertion is signed by a private key.

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

### -RequestedTokenUse
Specify the 'requested_token_use' you want to use.
For Azure AD, the only acceptable value is 'on_behalf_of'.
This is used to identify the on-behalf-of flow is to be used.

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

### -RequestedTokenType
Specify the 'requested_token_type'.
This is either... 
 - urn:ietf:params:oauth:token-type:saml2
 - urn:ietf:params:oauth:token-type:saml1

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
