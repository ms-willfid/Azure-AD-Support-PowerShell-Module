<#
.SYNOPSIS
Gets information for what access a user has access to.

.DESCRIPTION
Gets information for what access a user has access to.

.PARAMETER Id
Provide the User Principal Name or User Object ID

.EXAMPLE
Get-AadUserAccess -Id 'UserPrincipalName or User Object ID'

.NOTES
General notes
#>

function Get-AadUserAccess
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

    $user = Invoke-AadCommand -Command {
        Param($Id)
        Get-AzureAdUser -ObjectId $Id
    } -Parameters $Id
    
    if(-not $user)
    {
        throw "'$Id' not found in '$TenantDomain'"
    }

    Write-Host ""
    Write-Host "User Account" -ForegroundColor Yellow
    Write-Host "$($user.UserPrincipalName) | ObjectId:$($user.ObjectId)"
    Write-Host ""

    Write-Host "Getting Azure AD Directory Roles assigned to User..."
    $AdminRoles = Get-AadAdminRolesByObject -ObjectId $user.ObjectId | ConvertTo-Json

    Write-Host "Getting App Roles (Application Permissions) assigned to User..."
    $AppRoles = Get-AadAppRolesByObject -ObjectId $user.ObjectId -ObjectType $user.ObjectType | ConvertTo-Json

    Write-Host "Getting OAuth2PermissionGrants (Delegated Permissions) assigned to User..."
    $Grants = Get-AadConsent -UserId $user.ObjectId | ConvertTo-Json

    if(-not $SkipKeyVaultAccess)
    {
        Write-Host "Getting Key Vault Access assigned to User..."
        $KeyVaultAccess = Get-AadKeyVaultAccessByObject -ObjectId $user.ObjectId | ConvertTo-Json 
    }
    
    if(-not $SkipAzureRoleAssignments)
    {
        Write-Host "Getting Azure Roles assigned to User..."
        $AzureRoles = Get-AadAzureRoleAssignments -SigninName $user.UserPrincipalName | ConvertTo-Json
      
    }

    $Report = [pscustomobject]@{
        PrincipalType = $user.ObjectType
        PrincipalId = $user.UserPrincipalName
        PrincipalDisplayName = $user.DisplayName
        PrincipalObjectId = $user.ObjectId
        AzureAdAdminRoles = $AdminRoles;
        ApplicationRoles = $AppRoles;
        ConsentedPermissions = $Grants;
        KeyVaultAccess = $KeyVaultAccess;
        AzureRoleAssignments = $AzureRoles;
    }

    #$ReturnObject = New-Object -TypeName psobject -Property $Report

    return $Report
}
