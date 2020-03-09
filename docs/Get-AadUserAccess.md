---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Get-AadUserAccess

## SYNOPSIS
Gets information for what access a user has access to.

## SYNTAX

```
Get-AadUserAccess [-Id] <Object> [-SkipAzureRoleAssignments] [-SkipKeyVaultAccess] [<CommonParameters>]
```

## DESCRIPTION
Gets information for what access a user has access to.

## EXAMPLES

### EXAMPLE 1
```
Get-AadUserAccess -Id 'UserPrincipalName or User Object ID'
```

## PARAMETERS

### -Id
Provide the User Principal Name or User Object ID

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SkipAzureRoleAssignments
{{ Fill SkipAzureRoleAssignments Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipKeyVaultAccess
{{ Fill SkipKeyVaultAccess Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
