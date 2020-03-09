---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# ConvertFrom-AadJwtTime

## SYNOPSIS
Convert the long number format from JWT tokens to UTC

## SYNTAX

```
ConvertFrom-AadJwtTime [-JwtDateTime] <String> [<CommonParameters>]
```

## DESCRIPTION
Convert the long number format from JWT tokens to UTC
For example convert '1557162946' to '2019-05-06T22:15:46.0000000Z'

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-AadJwtTime 1557162946
```

## PARAMETERS

### -JwtDateTime
{{ Fill JwtDateTime Description }}

```yaml
Type: String
Parameter Sets: (All)
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
