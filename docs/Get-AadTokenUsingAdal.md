---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadTokenUsingAdal

## SYNOPSIS
Gets a token using ADAL installed with Azure AD PowerShell Module

## SYNTAX

### All (Default)
```
Get-AadTokenUsingAdal [-ClientId] <Object> [-ResourceId <Object>] [-Prompt <Object>] [-Tenant <Object>]
 [-Instance <Object>] [-SkipServicePrincipalSearch] [-HideOutput] [<CommonParameters>]
```

### ClientAccessToken
```
Get-AadTokenUsingAdal [-ClientId] <Object> [-ResourceId <Object>] [-Redirect <Object>] [-Prompt <Object>]
 [-Tenant <Object>] [-Instance <Object>] [-UseClientCredential] -ClientSecret <Object>
 [-SkipServicePrincipalSearch] [-HideOutput] [<CommonParameters>]
```

### UserAccessToken
```
Get-AadTokenUsingAdal [-ClientId] <Object> [-ResourceId <Object>] [-Redirect <Object>] [-UserId <Object>]
 [-Password <Object>] [-DomainHint <Object>] [-Prompt <Object>] [-Tenant <Object>] [-Instance <Object>]
 [-SkipServicePrincipalSearch] [-HideOutput] [<CommonParameters>]
```

### RopcFlow
```
Get-AadTokenUsingAdal [-ClientId] <Object> [-ResourceId <Object>] -UserId <Object> -Password <Object>
 [-Prompt <Object>] [-Tenant <Object>] [-Instance <Object>] [-UseResourceOwnerPasswordCredential]
 [-SkipServicePrincipalSearch] [-HideOutput] [<CommonParameters>]
```

## DESCRIPTION
Gets a token using ADAL installed with Azure AD PowerShell Module
Prompts user to sign-in in order to acquire token.

ClientID          : "ApplicationId-of-the-client-application"
TenantId          : "tenant-id"
AccessTokenClaims : @{ access-token-claims }
Scopes            : "scopes-in-access-token"
ExtraQueryParams  : "extra-query-parameters-used-to-get-token"
UserId            : "login_hint"
PromptBehavior    : "prompt-behavior-used-to-get-token"
ExpiresOn         : "when-the-token-expires"
Authority         : "authority"
IdToken           : "id-token"
IdTokenClaims     : @{ claims-in-the-id-token }
UniqueId          : "object-id-of-the-user"
ReplyAddress      : "reply-address-of-client-application"
AccessToken       : "access-token"
DisplayableId     : "user-principal-name-of-user"
AppId             : "ApplicationId-of-the-client-application"
Audience          : "ApplicationId-of-the-resource"
Resource          : "ApplicationId-of-the-resource"
Roles             : "roles-in-the-token"

## EXAMPLES

### EXAMPLE 1
```
Prompt user to sign-in to get access token
```

Get-AadTokenUsingAdal -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Native App' -Redirect "https://login.microsoftonline.com/common/oauth2/nativeclient"

To get client only access token
Get-AadTokenUsingAdal -UseClientCredential -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Service App' -ClientSecret "98iwjdc-098343js="

Use the Resource Owner Password Credential Flow or us WIA (Password required)
Get-AadTokenUsingAdal -UseResourceOwnerPasswordCredential -ResourceId "https://graph.microsoft.com" -ClientId 'Contoso Service App' -UserId 'your-user-name' -Password "your-secret-password"

## PARAMETERS

### -ClientId
Set the Client ID/App Id in which you want to get a access token from

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId
Set the resource in which you want to get a access token for

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://graph.microsoft.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -Redirect
Set the Redirect URL/URI for which Azure AD will redirect back to your application

```yaml
Type: Object
Parameter Sets: ClientAccessToken, UserAccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
Sets the user account to use when authenticating

```yaml
Type: Object
Parameter Sets: UserAccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: RopcFlow
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Sets the password for the user account being used if using the Resource Owner Password Credential method

```yaml
Type: Object
Parameter Sets: UserAccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: RopcFlow
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainHint
{{ Fill DomainHint Description }}

```yaml
Type: Object
Parameter Sets: UserAccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompt
Sets the prompt behavior for ADAL
'Always','Auto','SelectAccount','RefreshSession','Never'

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant
Sets the tenant in which your authenticating to
Used in conjunction with Instance to form the Authority

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Common
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
Sets the Azure AD Instance tenant in which your authenticating to
Used in conjunction with Tenant to form the Authority

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Https://login.microsoftonline.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseClientCredential
Tell ADAL to use the Client Credential flow (Gets a client only access token)

```yaml
Type: SwitchParameter
Parameter Sets: ClientAccessToken
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseResourceOwnerPasswordCredential
Tell ADAL to use the UserPasswordCredential method.
This is actually the Windows Integrated Authentication extension method in ADAL and can also be used for the Resource Owner Password Credential flow for non-federated users.

```yaml
Type: SwitchParameter
Parameter Sets: RopcFlow
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Sets the Client Secret for ADAL to use during Client Credential flow

```yaml
Type: Object
Parameter Sets: ClientAccessToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipServicePrincipalSearch
{{ Fill SkipServicePrincipalSearch Description }}

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

### -HideOutput
{{ Fill HideOutput Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
