---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# ConvertFrom-AadBase64Certificate

## SYNOPSIS
Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability

## SYNTAX

### Default (Default)
```
ConvertFrom-AadBase64Certificate [-Base64String] <String> [<CommonParameters>]
```

### Path
```
ConvertFrom-AadBase64Certificate [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-AadBase64Certificate -Base64String "MIIHkDCCBnigAwIBAgIRALENqydLHXg/u+VM04+dg2QwDQYJKoZIhvcNAQELBQAwgZ..."
```

## PARAMETERS

### -Base64String
The Base64Encoded Certificate

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
