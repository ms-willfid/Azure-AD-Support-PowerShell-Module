---
external help file: _RootModuleShared-help.xml
Module Name: AadSupportPreview
online version:
schema: 2.0.0
---

# Connect-AadSupport

## SYNOPSIS
Connect to the Azure AD Support PowerShell module.
This will use the same sign-in session to access different Microsoft resources.

## SYNTAX

```
Connect-AadSupport [[-TenantId] <Object>] [[-AccountId] <Object>] [[-Password] <Object>]
 [[-AzureEnvironmentName] <Object>] [-EnableLogging] [<CommonParameters>]
```

## DESCRIPTION
Connect to the Azure AD Support PowerShell module.
This will use the same sign-in session to access different Microsoft resources.

Example 1: Log in with your admin account...
Connect-AadSupport

Example 2: Log in to a specific tenant...
Connect-AadSupport -TenantId contoso.onmicrosoft.com

Example 3: Log in to a specific instance...
Connect-AadSupport -AzureEnvironmentName AzureCloud
Connect-AadSupport -AzureEnvironmentName AzureGermanyCloud
Connect-AadSupport -AzureEnvironmentName AzureChinaCloud
Connect-AadSupport -AzureEnvironmentName AzureUSGovernment

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -TenantId
Provide the Tenant ID you want to authenticate to.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Common
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountId
Provide the Account ID you want to authenticate with.

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

### -Password
{{ Fill Password Description }}

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

### -AzureEnvironmentName
Specifies the name of the Azure environment.
The acceptable values for this parameter are:

        - AzureCloud
        - AzureChinaCloud
        - AzureUSGovernment
        - AzureGermanyCloud

        The default value is AzureCloud.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: AzureCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableLogging
{{ Fill EnableLogging Description }}

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
