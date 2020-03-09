---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Import-AadAzureRoleAssignments

## SYNOPSIS
Import Azure RBAC Role Assignments from a CSV exported using Export-AadAzureRoleAssignments

## SYNTAX

```
Import-AadAzureRoleAssignments [-ImportCsv] <String> [-SubId] <String> [<CommonParameters>]
```

## DESCRIPTION
Import Azure RBAC Role Assignments from a CSV exported using Export-AadAzureRoleAssignments

## EXAMPLES

### EXAMPLE 1
```
Import-AadAzureRoleAssignments -SubId 'efb4bb0c-e454-4530-8753-753f22c8f901' -ImportCsv '.\Subscription--Pay-As-You-Go-Roles.csv'
```

## PARAMETERS

### -ImportCsv
Parameter description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubId
Parameter description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
