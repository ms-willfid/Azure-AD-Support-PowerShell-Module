---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadApplication

## SYNOPSIS
Intelligence to return the Application object by looking up using any of its identifiers.

## SYNTAX

### ByAnyId (Default)
```
Get-AadApplication [-Id] <Object> [<CommonParameters>]
```

### ByAppId
```
Get-AadApplication -AppId <Object> [<CommonParameters>]
```

### ByDisplayName
```
Get-AadApplication -DisplayName <Object> [<CommonParameters>]
```

### ByAppUriId
```
Get-AadApplication -AppUriId <Object> [<CommonParameters>]
```

### ByReplyAddress
```
Get-AadApplication -ReplyAddress <Object> [<CommonParameters>]
```

## DESCRIPTION
Intelligence to return the Application object by looking up using any of its identifiers.

## EXAMPLES

### EXAMPLE 1
```
Get-AadApplication -Id 'Contoso Web App'
```

## PARAMETERS

### -Id
Either specify Application Name, Display Name, Object ID, Application/Client ID, or Application Object ID

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

### -AppUriId
{{ Fill AppUriId Description }}

```yaml
Type: Object
Parameter Sets: ByAppUriId
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
Returns the Application object using Get-AzureAdApplication and filter based on the Id parameter

## RELATED LINKS
