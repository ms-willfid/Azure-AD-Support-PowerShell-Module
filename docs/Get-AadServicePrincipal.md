---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadServicePrincipal

## SYNOPSIS
Intelligence to return the service principal object by looking up using any of its identifiers.

## SYNTAX

### ByAnyId (Default)
```
Get-AadServicePrincipal [-Id] <Object> [<CommonParameters>]
```

### ByAppId
```
Get-AadServicePrincipal -AppId <Object> [<CommonParameters>]
```

### ByDisplayName
```
Get-AadServicePrincipal -DisplayName <Object> [<CommonParameters>]
```

### ByServicePrincipalName
```
Get-AadServicePrincipal -ServicePrincipalName <Object> [<CommonParameters>]
```

### ByReplyAddress
```
Get-AadServicePrincipal -ReplyAddress <Object> [<CommonParameters>]
```

## DESCRIPTION
Intelligence to return the service principal object by looking up using any of its identifiers.

## EXAMPLES

### EXAMPLE 1
```
Get-AadServicePrincipal -Id 'Contoso Web App'
```

## PARAMETERS

### -Id
Either specify Service Principal (SP) Name, SP Display Name, SP Object ID, Application/Client ID, or Application Object ID

```yaml
Type: Object
Parameter Sets: ByAnyId
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AppId
{{ Fill AppId Description }}

```yaml
Type: Object
Parameter Sets: ByAppId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
{{ Fill DisplayName Description }}

```yaml
Type: Object
Parameter Sets: ByDisplayName
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
Type: Object
Parameter Sets: ByServicePrincipalName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReplyAddress
{{ Fill ReplyAddress Description }}

```yaml
Type: Object
Parameter Sets: ByReplyAddress
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
Returns the Service Pricpal object using Get-AzureAdServicePradmin@wiincipal and filter based on the Id parameter

## RELATED LINKS
