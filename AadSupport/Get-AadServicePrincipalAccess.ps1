
<#
.SYNOPSIS
Gets information for what access a Service Principal/Application has access to.

.DESCRIPTION
Gets information for what access a Service Principal/Application has access to. 
Gets Azure AD Directory Roles assigned to Service Principal
Gets App Roles assigned to Service Principal
Gets Consented Permissions assigned to Service Principal
Gets Azure Role Assignments assigned to Service Principal (This one may take a while)
Gets Key Vault Access Policies assigned to Service Principal (This one may take a while)

.PARAMETER Id
Provide the Service Principal ID

.PARAMETER SkipAzureRoleAssignments
Enable switch to skip lookup of Azure Role Assignments.

.PARAMETER SkipKeyVaultAccess
Enable switch to skip lookup of Azure Key Vault Access policies.


.EXAMPLE
Get-AadServicePrincipalAccess -Id 'Your Application Name, AppId, or Service Principal Object Id'

.NOTES
General notes
#>
function Get-AadServicePrincipalAccess
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id,

        [switch]$SkipAzureRoleAssignments,
        [switch]$SkipKeyVaultAccess
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION
    

    $TenantDomain = $Global:AadSupport.Session.TenantDomain

    $sp = (Get-AadServicePrincipal -Id $Id)
    
    if(-not $sp)
    {
        throw "'$Id' not found in '$TenantDomain'"
    }

    Write-Host ""
    Write-Host "Enterprise App (ServicePrincipal)" -ForegroundColor Yellow
    Write-Host "$($sp.DisplayName) | AppId:$($sp.AppId) | ObjectId:$($sp.ObjectId)"
    Write-Host ""

    if($sp.count -gt 1)
    {
        throw "'$Id' query returned more than one result. Please provide a unique Service Principal Identifier"
    }

    Write-Host "Getting Azure AD Directory Roles assigned to Service Principal..."
    $AdminRoles = Get-AadAdminRolesByObject -ObjectId $sp.ObjectId | ConvertTo-Json

    Write-Host "Getting App Roles (Application Permissions) assigned to Service Principal..."
    $AppRoles = Get-AadAppRolesByObject -ObjectId $sp.ObjectId -ObjectType $sp.ObjectType | ConvertTo-Json

    Write-Host "Getting OAuth2PermissionGrants (Delegated Permissions) assigned to Service Principal..."
    $Grants = Get-AadConsent -ClientId $sp.ObjectId | ConvertTo-Json

    if(-not $SkipKeyVaultAccess)
    {
        Write-Host "Getting Key Vault Access assigned to Service Principal..."
        $KeyVaultAccess = Get-AadKeyVaultAccessByObject -ObjectId $sp.ObjectId | ConvertTo-Json 
    }
    
    if(-not $SkipAzureRoleAssignments)
    {
        Write-Host "Getting Azure Roles assigned to Service Principal..."
        $AzureRoles = Get-AadAzureRoleAssignments -ServicePrincipalName $sp.ServicePrincipalNames[0] -ObjectId $sp.ObjectId | ConvertTo-Json
      
    }

    $Report = [pscustomobject]@{
        PrincipalType = $sp.ObjectType
        PrincipalId = $sp.AppId
        PrincipalDisplayName = $sp.DisplayName
        PrincipalObjectId = $sp.ObjectId
        AzureAdAdminRoles = $AdminRoles;
        ApplicationRoles = $AppRoles;
        ConsentedPermissions = $Grants;
        KeyVaultAccess = $KeyVaultAccess;
        AzureRoleAssignments = $AzureRoles;
    }

    #$ReturnObject = New-Object -TypeName psobject -Property $Report

    return $Report
}






