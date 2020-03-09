---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# ConvertFrom-AadJwtToken

## SYNOPSIS
Convert a base64Encoded Json Web Token to a PowerShell object.
#

## SYNTAX

```
ConvertFrom-AadJwtToken [-Token] <String> [<CommonParameters>]
```

## DESCRIPTION
Convert a base64Encoded Json Web Token to a PowerShell object.

## EXAMPLES

### EXAMPLE 1
```
EXAMPLE 1
```

"eyJ***" | ConvertFrom-AadJwtToken

EXAMPLE 2
ConvertFrom-AadJwtToken -Token "eyJ***"

## PARAMETERS

### -Token
Parameter description

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
