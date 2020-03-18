---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadAppRolesByObject

## SYNOPSIS
Get the App roles assigned to the specified object

## SYNTAX

### ByServicePrincipalId
```
Get-AadAppRolesByObject -ServicePrincipalId <Object> [-ObjectId <Object>] [-ObjectType <Object>]
 [<CommonParameters>]
```

### ByObjectId
```
Get-AadAppRolesByObject -ObjectId <Object> [-ObjectType <Object>] [<CommonParameters>]
```

### ByUserId
```
Get-AadAppRolesByObject [-ObjectId <Object>] [-ObjectType <Object>] -UserId <Object> [<CommonParameters>]
```

## DESCRIPTION
Get the App roles assigned to the specified object

## EXAMPLES

### EXAMPLE 1
```
Get-AadAppRolesByObject -ServicePrincipalId 'Contoso App'
```

ResourceDisplayName : Microsoft Graph
ResourcePermission  : User.ReadWrite.All
DirectAssignment    : True
GetsAssignmentBy    :
Id                  : ef7d1fa9-1e37-48fd-bb58-ad10a78cbd18

## PARAMETERS

### -ServicePrincipalId
Specify by the Service Principal

```yaml
Type: Object
Parameter Sets: ByServicePrincipalId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectId
Specify by any object ID

```yaml
Type: Object
Parameter Sets: ByServicePrincipalId, ByUserId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: ByObjectId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ObjectType
Specify the Object type based on Object id specified

```yaml
Type: Object
Parameter Sets: ByServicePrincipalId, ByUserId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: ByObjectId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserId
Specify the User

```yaml
Type: Object
Parameter Sets: ByUserId
Aliases:

Required: True
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
