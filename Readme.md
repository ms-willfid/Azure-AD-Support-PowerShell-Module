# Azure AD Support PowerShell Module

## Disclaimer

Use this PowerShell module at your own risk. There is no support model for this PowerShell module except through this github repository. Please report any issues here... 
https://github.com/ms-willfid/aad-support-psh-module/issues

This PowerShell module is intended to help support, troubleshoot, and diagnose issues with common Azure AD issues such as application integration and sign-in failures.

DO NOT USE this PowerShell module for production and do not have any dependency on any of the cmdlets.

Cmdlets may change at any time without notice.

Best regards,
Bill Fiddes

## Install

To install the Azure AD Support PowerShell Module...

> Install-Module AadSupport

## Version History
0.2.6
* Now forcing user to call Connect-AadSupport
* Added Delete HttpMethod for Invoke-AadProtectedApi
* Added Get-AadApplication (Alias Get-AadApp)
* When calling Get-AadToken or Get-AadTokenUsingAdal, Access Token claims are not printed to screen
* When multiple results are returned from Get-AadServicePrincipal, Now presents user with dialog to pick one
* Added Azure Roles to Service Principal Access (Get-AadServicePrincipalAccess)
* Added cmdlet to export Azure Role Assignments
* Added cmdlet to import Azure Role Assignments
* Fixed some bugs with getting tokens silently