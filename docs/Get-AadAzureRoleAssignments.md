---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadAzureRoleAssignments

## SYNOPSIS
{{ Fill in the Synopsis }}

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
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ObjectId
{{ Fill ObjectId Description }}

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
{{ Fill ObjectType Description }}

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
{{ Fill ServicePrincipalId Description }}

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

### -ServicePrincipalName
{{ Fill ServicePrincipalName Description }}

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
{{ Fill SigninName Description }}

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

### -UserId
{{ Fill UserId Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
