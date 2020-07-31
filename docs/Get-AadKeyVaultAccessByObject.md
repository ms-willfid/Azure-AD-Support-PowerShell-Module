---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadKeyVaultAccessByObject

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ByObjectId
```
Get-AadKeyVaultAccessByObject [-ObjectId <Object>] [-ObjectType <String>] [<CommonParameters>]
```

### ByServicePrincipalId
```
Get-AadKeyVaultAccessByObject [-ObjectType <String>] [-ServicePrincipalId <Object>] [<CommonParameters>]
```

### ByUserId
```
Get-AadKeyVaultAccessByObject [-ObjectType <String>] [-UserId <Object>] [<CommonParameters>]
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
Type: Object
Parameter Sets: ByObjectId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ObjectType
{{ Fill ObjectType Description }}

```yaml
Type: String
Parameter Sets: ByObjectId
Aliases:
Accepted values: User, ServicePrincipal

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByServicePrincipalId, ByUserId
Aliases:
Accepted values: User, ServicePrincipal

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServicePrincipalId
{{ Fill ServicePrincipalId Description }}

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
{{ Fill UserId Description }}

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

### System.Object

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
