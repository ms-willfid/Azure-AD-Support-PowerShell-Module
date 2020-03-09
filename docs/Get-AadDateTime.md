---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadDateTime

## SYNOPSIS
Azure AD uses the UTC time (Coordinated Universal Time) and Universal Sortable DateTime Pattern.

## SYNTAX

```
Get-AadDateTime [[-DateTime] <Object>] [[-AddDays] <Object>] [[-AddHours] <Object>] [[-AddMinutes] <Object>]
 [[-AddYears] <Object>] [[-AddMonths] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Azure AD uses the UTC time (Coordinated Universal Time) and Universal Sortable DateTime Pattern.

UTC is the worlds synchronized time and set to the GMT time zone.
Universal Sortable DateTime Pattern looks like this: yyyy-MM-dd'T'HH:mm:ss.SSSZ

## EXAMPLES

### EXAMPLE 1
```
Get-AadDateTime
```

Get-AadDateTime -DateTime "01/20/2019"
Get-AadDateTime -AddDays 7 -AddHours 12 -AddMinutes 30
Get-AadDateTime -DateTime "01/20/2019" -AddDays -7

## PARAMETERS

### -DateTime
Specify DateTime you want to convert to UTC

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AddDays
Add or subtract days from current DateTime or specified DateTime

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddHours
Add or subtract hours from current DateTime or specified DateTime

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddMinutes
Add or subtract minutes from current DateTime or specified DateTime

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddYears
{{ Fill AddYears Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddMonths
{{ Fill AddMonths Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
