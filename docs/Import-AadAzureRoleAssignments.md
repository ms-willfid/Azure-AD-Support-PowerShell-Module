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

We also try to map external guest accounts to accounts that exist in the tenant you are importing to.

When running this cmdlet, you may see the following messages...
* Assigning to scope '/' level not allowed
  \> This is a Azure AD tenant setting where the user has enabled 'Access management for Azure resources'
  \> https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin
* This is a Unknown Role Assignment.
  \> This object probably does not exist anymore in the Azure AD tenant.

## EXAMPLES

### EXAMPLE 1
```
Import-AadAzureRoleAssignments -SubId 'efb4bb0c-e454-4530-8753-753f22c8f901' -ImportCsv '.\Subscription--Pay-As-You-Go-Roles.csv'
```

## PARAMETERS

### -ImportCsv
Provide the Azure subscription CSV file exported from 'Export-AadAzureRoleAssignments'

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
Provide the Azure subscription ID you want to import into.

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
