---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadTenantAdmins

## SYNOPSIS
Gets a list of tenant admins.

## SYNTAX

### All (Default)
```
Get-AadTenantAdmins [<CommonParameters>]
```

### UseRole
```
Get-AadTenantAdmins [[-Role] <Object>] [<CommonParameters>]
```

### GetAll
```
Get-AadTenantAdmins [-All] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of tenant admins.

## EXAMPLES

### EXAMPLE 1
```
Get-AadTenantAdmins
```

...See a list of company admins...

### EXAMPLE 2
```
Get-AadTenantAdmins -Role 'Helpdesk Administrator'
```

...See a list of password or helpdesk admins...

### EXAMPLE 3
```
Get-AadTenantAdmins -Role 8da6f8d3-ef75-42e4-961e-8fba79c29048
```

...You can also use Role Ids...

### EXAMPLE 4
```
Get-AadTenantAdmins -All
```

...You can see a list of all Admin Roles...

## PARAMETERS

### -Role
Provide the role to lookup
By Default 'Company Administrator' is used

```yaml
Type: Object
Parameter Sets: UseRole
Aliases:

Required: False
Position: 1
Default value: Company Administrator
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: GetAll
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
