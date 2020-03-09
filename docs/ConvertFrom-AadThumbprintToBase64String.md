---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# ConvertFrom-AadThumbprintToBase64String

## SYNOPSIS
Converts a Thumbprint to a Base64Encoded Thumbprint or also known as Key Identifier (Kid)

## SYNTAX

```
ConvertFrom-AadThumbprintToBase64String [-Thumbprint] <String> [<CommonParameters>]
```

## DESCRIPTION
Converts a Thumbprint to a Base64Encoded Thumbprint or also known as Key Identifier (Kid)

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-AadThumbprintToBase64String -Base64String 'CF-BF-51-9C-69-63-4D-06-BD-66-1E-19-8C-BA-BA-51-A0-78-79-43'
```

ConvertFrom-AadThumbprintToBase64String -Base64String 'CFBF519C69634D06BD661E198CBABA51A0787943'

Output...
z79RnGljTQa9Zh4ZjLq6UaB4eUM=

## PARAMETERS

### -Thumbprint
Provide the Thumbprint to be converted to a Base64Encoded value

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

## RELATED LINKS
