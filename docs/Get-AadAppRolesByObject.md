---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadAppRolesByObject

## SYNOPSIS
#

## SYNTAX

### ByServicePrincipalId
```
Get-AadAppRolesByObject -ServicePrincipalId <Object> [-ObjectId <Object>] [-ObjectType <Object>]
 [<CommonParameters>]
```

### ByObjectId
```
Get-AadAppRolesByObject -ObjectId <Object> -ObjectType <Object> [<CommonParameters>]
```

### ByUserId
```
Get-AadAppRolesByObject [-ObjectId <Object>] [-ObjectType <Object>] -UserId <Object> [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
An example
```

## PARAMETERS

### -ServicePrincipalId
{{ Fill ServicePrincipalId Description }}

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
Parameter description

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
{{ Fill ObjectType Description }}

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

### -UserId
{{ Fill UserId Description }}

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
