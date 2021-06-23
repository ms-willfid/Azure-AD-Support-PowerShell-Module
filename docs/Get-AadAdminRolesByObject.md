---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadAdminRolesByObject

## SYNOPSIS
Gets the admin roles assigned to the specified object (User or ServicePrincipal)

## SYNTAX

### ByObjectId
```
Get-AadAdminRolesByObject [-ObjectId <Object>] [<CommonParameters>]
```

### ByServicePrincipalId
```
Get-AadAdminRolesByObject [-ObjectId <Object>] [-ServicePrincipalId <Object>] [<CommonParameters>]
```

### ByUserId
```
Get-AadAdminRolesByObject [-ObjectId <Object>] [-UserId <Object>] [<CommonParameters>]
```

## DESCRIPTION
Gets the admin roles assigned to the specified object (User or ServicePrincipal)

Example 1: Get Admin Roles for a User or Object based on its ObjectId
Get-AadAdminRolesByObject -ObjectId 

Example 2: Get Admin Roles for a ServicePrincipal
Get-AadAdminRolesByObject -ServicePrincipalId 'Contoso Web App'

Example 3: Get Admin Roles for a user
Get-AadAdminRolesByObject -UserId 'john@contoso.com'

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ObjectId
Lookup user or service principal by its ObjectId

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ServicePrincipalId
Lookup service principal by any of its Ids (DisplayName, AppId, ObjectId, or SPN)

```yaml
Type: Object
Parameter Sets: ByServicePrincipalId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
Lookup user by any of its Ids ObjectId or UserPrincipalName

```yaml
Type: Object
Parameter Sets: ByUserId
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
