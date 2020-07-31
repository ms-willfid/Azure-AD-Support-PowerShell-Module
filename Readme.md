# Azure AD Support PowerShell Module

## Disclaimer

Use this PowerShell module at your own risk. There is no support model for this PowerShell module except through this github repository. Please report any issues here... 
https://github.com/ms-willfid/aad-support-psh-module/issues

This PowerShell module is intended to help support, troubleshoot, diagnose, and provide quick fixes for common Azure AD issues such as application integration and sign-in failures.

DO NOT USE this PowerShell module for production and do not have any dependency on any of the cmdlets. Expect breaking changes and no SLA on resolving issues within this PowerShell module.

Cmdlets may change at any time without notice.

Best regards,
Will Fiddes

## Install

To install the Azure AD Support PowerShell Module...

> Install-Module AadSupport


## Connect

To Sign in with your user and start using the cmdlets available for this module...

> Connect-AadSupport

## Announcements

* I will be deprecating Set-AadConsent
  * Please use Revoke-AadConsnet or Add-AadConsent respectively.

## Version History

### 0.3.7 | Jul-31-2020
* Added New-AadClientAssertion
* Added New-AadApplicationCertificate
* Added Find-AadAppPermission
* Added Add-AadConsent
* Added additional support in Validate-AadToken and Get-AadDiscoveryKeys for third-party IdPs
* Other bug fixes (There are always bugs)

### 0.3.4 | May-11 2020
* Added ConvertTo-AadBase64EncodedString
* Other bug fixes

### 0.3.3 | Mar-18 2020
* Added Test-AadToken (alias Validate-AadToken)
* Added Get-AadOpenIdConnectConfiguration
* Added Get-AadReportMfaEnabled
* Added Get-AadReportMfaNotEnrolled
* Made changes to Get-AadDiscoveryKeys (now leverages Get-AadOpenIdConnectConfiguration)
* Renamed cmdlet from 'Get-AadReportUserMfaEnrollment' to 'Get-AadReportMfaEnrolled'
* And as usual fixed more bugs
  * Revoke-AadConent now fixed
  * ConvertFrom-AadThumbprintToBase64String now Url Decodes

### 0.3.1 | Mar-9 2020
* Found and fixed a few bugs.

### 0.3.0 | Mar-8 2020
* Added Get-AadConsent : Perform queries on all consented permissions (much more flexible than Get-AadConsentedPermissions)
* Removing Get-AadConsentedPermissions
* Added Revoke-AadConsent : Revoke any consent
* Update to Get-AadTokenUsingAdal to now support Resource Owner Password Credential flow (using ADAL)  
* Update to Get-AadObjectCount that now accounts for objects that counts against your Quota
* Fixed a bug when using MSOnline PowerShell module breaks the usage of this module
* Fixed bug in Get-AadTokenUsingAdal where you could not use a display name for the ResourceId
* Fixed other random bugs. Who knows maybe created more undetected bugs.

### 0.2.8 | Oct-2 2019
* Added Get-AadReportCredentialsExpiringSoon : Lists all Apps and service principals where Key Credentials and Password credentials are about to expire
* Added Get-AadReportUserMfaEnrollment : Lists Users who have enrolled for MFA
* When using Invoke-AadProtectedApi for MS Graph, added pagination so all results will be returned.
* Fixed bug with Get-AadObjectCount

### 0.2.7
* Get-AadServicePrincipalAccess Now does transitive group membership lookup
* Added user version of Get-AadServicePrincipalAcces called Get-AadUserAccess
* Added or rather exposed my internal calls for Get-AadServicePrincipalAccess (Re-worked them to support Get-AadUserAccess and allow output to file)
    * Get-AadKeyVaultAccessByObject
    * Get-AadConsentedPermissions
    * Get-AadAzureRoleAssignments
    * Get-AadAppRolesByObject
    * Get-AadAdminRolesByObject
* Added Get-AadDiscoveryKeys (Gets the public certs used to verify signatures)
* Added Get-AadUserRealm (Calls GetUserRealm)
* Removed Alies(es). It was causing confusion for testers
* Added additional parameters to Get-AadToken to allow flexible token request...
    * GrantType
    * Code
    * Assertion
    * ClientAssertionType
    * ClientAssertion
    * RequestedTokenUse
    * RequestedTokenType
* Added Get-AadObjectCount (How many objects in Azure AD that counts against Directory Quota)
* And as usual squashing some bugs

### 0.2.6
* Now forcing user to call Connect-AadSupport
* Added Delete HttpMethod for Invoke-AadProtectedApi
* Added Get-AadApplication (Alias Get-AadApp)
* When calling Get-AadToken or Get-AadTokenUsingAdal, Access Token claims are not printed to screen
* When multiple results are returned from Get-AadServicePrincipal, Now presents user with dialog to pick one
* Added Azure Roles to Service Principal Access (Get-AadServicePrincipalAccess)
* Added cmdlet to export Azure Role Assignments
* Added cmdlet to import Azure Role Assignments
* Fixed some bugs with getting tokens silently