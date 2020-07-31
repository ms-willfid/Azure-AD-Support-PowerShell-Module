---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadConsent

## SYNOPSIS
Get a list of consented permissions based using the specified parameters to filter

## SYNTAX

```
Get-AadConsent [[-ClientId] <String>] [[-ResourceId] <String>] [[-UserId] <String>] [[-ConsentType] <Object>]
 [[-PermissionType] <Object>] [[-ClaimValue] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get a list of consented permissions based using the specified parameters to filter

Get-AadConsent Returns the following Object with properties
PermissionType | Expected values: Role, Scope | Role if Application permission, Scope if Delegated permission
ClientName | Name of the client
ClientId | Service Principal Object ID of the client
ResourceName | Name of the resource
ResourceId  | Service Principal Object ID of the resource
PrincipalId | Service Principal Object ID of the user
Permissions | List of scopes or role claim values
Id | Id of the OAuth2PermissionGrant/AppRole
ConsentType | Expected values: AdminConsent, UserConsent

## EXAMPLES

### EXAMPLE 1
```
Example 1: See a list of all consents for a app
```

PS C:\\\> Get-AadConsent -ClientId 'Contoso App' | Format-List

### EXAMPLE 2
```
Example 2: See a list of User Consents for a app
```

PS C:\\\> Get-AadConsent -ClientId 'Contoso App' -UserId john@contoso.com | Format-List

## PARAMETERS

### -ClientId
Filter based on the ClientId.
This is the Enterprise App (Client app) in which the consented permissions are applied on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
Filter based on the UserId.
User in which that has consented to the app.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: 4
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
Position: 5
Default value: All
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
