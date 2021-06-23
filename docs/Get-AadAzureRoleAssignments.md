---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadAzureRoleAssignments

## SYNOPSIS
Get the Azure Roles assigned to the specified object

## SYNTAX

### ByObject (Default)
```
Get-AadAzureRoleAssignments -ObjectId <String> [-ObjectType <String>] [<CommonParameters>]
```

### ByServicePrincipalObject
```
Get-AadAzureRoleAssignments -ObjectId <String> [-ObjectType <String>] [-ServicePrincipalName <String>]
 [<CommonParameters>]
```

### ByServicePrincipalId
```
Get-AadAzureRoleAssignments [-ObjectId <String>] [-ObjectType <String>] -ServicePrincipalId <String>
 [<CommonParameters>]
```

### ByUserId
```
Get-AadAzureRoleAssignments [-ObjectId <String>] [-ObjectType <String>] -UserId <String> [<CommonParameters>]
```

### ByServicePrincipalName
```
Get-AadAzureRoleAssignments [-ObjectId <String>] [-ObjectType <String>] -ServicePrincipalName <String>
 [<CommonParameters>]
```

### BySigninName
```
Get-AadAzureRoleAssignments [-ObjectId <String>] [-ObjectType <String>] -SigninName <String>
 [<CommonParameters>]
```

## DESCRIPTION
Get the Azure Roles assigned to the specified object

## EXAMPLES

### EXAMPLE 1
```
Get-AadAzureRoleAssignments -ServicePrincipalId 'Contoso App'
```

ResourceDisplayName : Microsoft Graph
ResourcePermission  : User.ReadWrite.All
DirectAssignment    : True
GetsAssignmentBy    :
Id                  : ef7d1fa9-1e37-48fd-bb58-ad10a78cbd18

## PARAMETERS

### -ObjectId
Specify by any object ID

```yaml
Type: String
Parameter Sets: ByObject, ByServicePrincipalObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByServicePrincipalId, ByUserId, ByServicePrincipalName, BySigninName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectType
Specify the Object type based on Object id specified

```yaml
Type: String
Parameter Sets: ByObject, ByServicePrincipalObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByServicePrincipalId, ByUserId, ByServicePrincipalName, BySigninName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServicePrincipalId
Specify by the Service Principal

```yaml
Type: String
Parameter Sets: ByServicePrincipalId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
Specify the User

```yaml
Type: String
Parameter Sets: ByUserId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServicePrincipalName
Specify the ServicePrincipalName

```yaml
Type: String
Parameter Sets: ByServicePrincipalObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByServicePrincipalName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SigninName
Specify the SigninName

```yaml
Type: String
Parameter Sets: BySigninName
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
