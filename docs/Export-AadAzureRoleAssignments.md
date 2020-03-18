---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Export-AadAzureRoleAssignments

## SYNOPSIS
Exports all Azure Role Assignments from all subscriptions in which you have read access to.

## SYNTAX

```
Export-AadAzureRoleAssignments
```

## DESCRIPTION
Exports all Azure Role Assignments from all subscriptions in which you have read access to.

This will output a series of files...
* Separate CSV for each group and their Group Memberships
* Separate CSV for each Azure subscription and their Azure Role Assignments
* Single CSV that contains all subscriptions and all Azure ROle Assignments
* Single HTML that contains all subscriptions and all Azure ROle Assignments

Output of running this command will look something like this...

Skipping 'Access to Azure Active Directory'.
This is not going to have Role Assignments.
Analyzing Subscription 'Pay-As-You-Go (Id:92aa81c9-af09-4ea2-ade0-72a1b4073dbe)'
Exported Group Memberships
 \> C:\temp\GroupMembers--DynamicGroup.csv
Exported Subscription Role Assignments
 \> C:\temp\Subscription--Pay-As-You-Go-Roles.csv
Analyzing Subscription 'Windows Azure MSDN - Visual Studio Ultimate (Id:955107ad-af96-475e-a9e9-0b0474e83982)'
Exported Group Memberships
 \> C:\temp\GroupMembers--Application Access - 4.csv
Exported Group Memberships
 \> C:\temp\GroupMembers--Group 1.csv
Exported Subscription Role Assignments
 \> C:\temp\Subscription--Windows Azure MSDN - Visual Studio Ultimate-Roles.csv
Analyzing Subscription 'Microsoft Azure Internal Consumption (Id:ef8110a7-ab02-4b82-a4d1-4126dcda86e0)'
Exported Subscription Role Assignments
 \> C:\temp\Subscription--Microsoft Azure Internal Consumption-Roles.csv
Exported All Role Assignments
 \> C:\temp\Subscription--All-Roles.csv
Exported HTML
 \> C:\temp\Subscription--All-Roles.html


Please verify the contents of the exported files.

You can use either the 'Subscription--All-Roles.csv' or one of the subscription files to import the Azure Role Assignments into another tenant or into another Azure subscription when running...
Import-AadAzureRoleAssignments

## EXAMPLES

### EXAMPLE 1
```
Export-AadAzureRoleAssignments
```

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
