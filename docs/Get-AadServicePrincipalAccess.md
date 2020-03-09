---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadServicePrincipalAccess

## SYNOPSIS
Gets information for what access a Service Principal/Application has access to.

## SYNTAX

```
Get-AadServicePrincipalAccess [-Id] <Object> [-SkipAzureRoleAssignments] [-SkipKeyVaultAccess]
 [<CommonParameters>]
```

## DESCRIPTION
Gets information for what access a Service Principal/Application has access to. 
Gets Azure AD Directory Roles assigned to Service Principal
Gets App Roles assigned to Service Principal
Gets Consented Permissions assigned to Service Principal
Gets Azure Role Assignments assigned to Service Principal (This one may take a while)
Gets Key Vault Access Policies assigned to Service Principal (This one may take a while)

## EXAMPLES

### EXAMPLE 1
```
Get-AadServicePrincipalAccess -Id 'Your Application Name, AppId, or Service Principal Object Id'
```

## PARAMETERS

### -Id
Provide the Service Principal ID

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
Enable switch to skip lookup of Azure Role Assignments.

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
Enable switch to skip lookup of Azure Key Vault Access policies.

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
