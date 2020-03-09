---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Set-AadConsent

## SYNOPSIS
# Resolve Admin Consent Issues

## SYNTAX

### All (Default)
```
Set-AadConsent [-ClientId] <String> [-Scopes <String>] [-Roles <String>] [-UserId <String>] [-Expires <Object>]
 [<CommonParameters>]
```

### UseOtherResource
```
Set-AadConsent [-ClientId] <String> -ResourceId <String> [-Scopes <String>] [-Roles <String>]
 [-UserId <String>] [-Expires <Object>] [<CommonParameters>]
```

### UseMsGraph
```
Set-AadConsent [-ClientId] <String> [-UseMsGraph] [-Scopes <String>] [-Roles <String>] [-UserId <String>]
 [-Expires <Object>] [<CommonParameters>]
```

### UseAadGraph
```
Set-AadConsent [-ClientId] <String> [-UseAadGraph] [-Scopes <String>] [-Roles <String>] [-UserId <String>]
 [-Expires <Object>] [<CommonParameters>]
```

## DESCRIPTION
# Resolve Admin Consent Issues when the application registration is in a external directory and it not configured correctly.

## EXAMPLES

### EXAMPLE 1
```
Set-AadConsent -Id 'Your App Name' -Scopes 'User.Read Directory.Read.All' -UseMsGraph
```

Applies Admin Consent for the Microsoft Graph permissions User.Read & Directory.Read.All

### EXAMPLE 2
```
Set-AadConsent -Id 'Your App Name' -Scopes 'User.Read Directory.Read.All' -UseMsGraph -UserId john@contoso.com
```

Applies User Consent on user john@contoso.com for the Microsoft Graph permissions User.Read & Directory.Read.All

### EXAMPLE 3
```
Set-AadConsent -Id 'Your App Name' -Scopes 'user_impersonation' -ResourceId 'Custom Api'
```

You can also consent for custom API

## PARAMETERS

### -ClientId
{{ Fill ClientId Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceId
Identifier for the Resource (ServicePrincipal) we will be consenting permissions to.

```yaml
Type: String
Parameter Sets: UseOtherResource
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseMsGraph
Set permission scopes for https://graph.microsoft.com

```yaml
Type: SwitchParameter
Parameter Sets: UseMsGraph
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseAadGraph
Set permission scopes for https://graph.windows.net

```yaml
Type: SwitchParameter
Parameter Sets: UseAadGraph
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
scope permissions

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

### -Roles
{{ Fill Roles Description }}

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

### -UserId
If you set a UserId, then it will use User Consent

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

### -Expires
Set the date when these consent scope permissions (OAuth2PermissionGrants) expire.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-AadDateTime -AddMonths 12)
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
