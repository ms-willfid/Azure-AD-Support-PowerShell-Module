---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Revoke-AadConsent

## SYNOPSIS
Get a list of consented permissions based using the specified parameters to filter

## SYNTAX

### All (Default)
```
Revoke-AadConsent [-ClientId] <String> [-ResourceId <String>] [-ClaimValue <String>] [-ConsentType <Object>]
 [-PermissionType <Object>] [<CommonParameters>]
```

### UserId
```
Revoke-AadConsent [-ClientId] <String> [-ResourceId <String>] [-ClaimValue <String>] [-UserId <String>]
 [-ConsentType <Object>] [-PermissionType <Object>] [<CommonParameters>]
```

## DESCRIPTION
Revokes a consented permission based on the parameters provided to be used as a filter.
At minimum, the ClientId is required.

## EXAMPLES

### EXAMPLE 1
```
Example 1: Remove all consented permissions for a app (Removes All Admin and User Consents)
```

PS C:\\\> Revoke-AadConsent -ClientId 'Contoso App'

### EXAMPLE 2
```
Example 2: Remove all user consented permissions leaving only the Admin consented permissions
```

PS C:\\\> Revoke-AadConsent -ClientId 'Contoso App' -ConsentType User

### EXAMPLE 3
```
Example 3: Revoke a specific permission
```

PS C:\\\> Revoke-AadConsent -ClientId 'Contoso App' -ResourceId 'Microsoft Graph' -ClaimValue Directory.ReadWrite.All

### EXAMPLE 4
```
Example 4: Revoke a specific user
```

PS C:\\\> Revoke-AadConsent -ClientId 'Contoso App' -UserId 'john@contoso.com'

## PARAMETERS

### -ClientId
Filter based on the ClientId.
This is the Enterprise App (Client app) in which the consented permissions are applied on.

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
Filter based on the ResourceId.
This is the resource in which the client has permissions on.

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

### -ClaimValue
Filter based on the scope or role value.

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
Filter based on the UserId.
User in which that has consented to the app.

```yaml
Type: String
Parameter Sets: UserId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConsentType
Filter based on the Consent Type.
Available options...
'Admin','User', 'All'

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -PermissionType
Filter based on the Permission Type.
Available options...
'Delegated','Application', 'All'

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
