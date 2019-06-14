
<#
.SYNOPSIS
Gets information for what access a Service Principal/Application has access to.

.DESCRIPTION
Gets information for what access a Service Principal/Application has access to.

.PARAMETER Id
Provide the Service Principal ID

.EXAMPLE
Get-AadServicePrincipalAccess -Id 'Your Application Name, AppId, or Service Principal Object Id'

.NOTES
General notes
#>
Set-Alias -Name Get-AadSpAccess -Value Get-AadServicePrincipalAccess
function Get-AadServicePrincipalAccess
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
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

    Write-Host "Enterprise App (ServicePrincipal)" -ForegroundColor Yellow
    $sp | Select-Object DisplayName, AppId, ObjectId | Format-Table 

    if($sp.count -gt 1)
    {
        throw "'$Id' query returned more than one result. Please provide a unique Service Principal Identifier"
    }


    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Getting Azure AD Directory Roles assigned to Service Principal..." -ForegroundColor Yellow
    Get-AadServicePrincipalAdminRoles -ObjectId $sp.ObjectId

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Getting App Roles (Application Permissions) assigned to Service Principal..." -ForegroundColor Yellow
    Get-AadServicePrincipalAppRoles -ObjectId $sp.ObjectId

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Getting OAuth2PermissionGrants (Delegated Permissions) assigned to Service Principal..." -ForegroundColor Yellow
    Get-AadServicePrincipalGrants -ObjectId $sp.ObjectId

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Getting Key Vault Access assigned to Service Principal..." -ForegroundColor Yellow
    Get-AadServicePrincipalKeyVaultAccess -ObjectId $sp.ObjectId

    Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Host "Getting Azure Roles assigned to Service Principal..." -ForegroundColor Yellow
    Get-AadServicePrincipalAzureRoles -Id $sp.ServicePrincipalNames[0]
}


<#
.SYNOPSIS
#

.DESCRIPTION
Long description

.PARAMETER ObjectId
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Set-Alias -Name Get-AadSpAdminRoles -Value Get-AadServicePrincipalAdminRoles
function Get-AadServicePrincipalAdminRoles {
# THIS FUNCTION IS STANDALONE
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $ObjectId
    )


    $roles = Get-AzureADDirectoryRole
    $AdminRoleList = @()

    $AadAdminCount = 0
    foreach ($role in $roles) {
        $members = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
        foreach ($member in $members) {
            if($member.ObjectId -eq $ObjectId) {
                $AdminRoleList += [PSCustomObject]@{
                    RoleDisplayName = $role.DisplayName;
                    RoleId = $role.ObjectId;
                }
                $AadAdminCount++
            }
        } 
    }

    # Output Admin Roles
    $AdminRoleList | Format-Table RoleDisplayName, RoleId

    if ($AadAdminCount -eq 0) {
        Write-Host "None"
        Write-Host ""
        return
    }

    Write-Host "To remove a Directory Role... (Example)"
    $ExampleId = $AdminRoleList[0].RoleId
    Write-Host "Remove-AzureADDirectoryRoleMember -ObjectId $ExampleId -MemberId $ObjectId"
    Write-Host ""

}


<#
.SYNOPSIS
#

.DESCRIPTION
Long description

.PARAMETER ObjectId
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Set-Alias -Name Get-AadSpGrants -Value Get-AadServicePrincipalGrants
function Get-AadServicePrincipalGrants {
# THIS FUNCTION IS STANDALONE
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $ObjectId
    )

    $GrantList = @()

    $grants = Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $ObjectId
    $count = 0
    foreach ($grant in $grants) {
        
        $resource = (Get-AzureADServicePrincipal -ObjectId $grant.ResourceId)

        if ($grant.ConsentType -eq "AllPrincipals") {
            $PrincipalId = "AllPrincipals"
        }
        else {
            $PrincipalId = (Get-AzureAdUser -ObjectId $grant.PrincipalId).UserPrincipalName
        }

        $GrantList += [PSCustomObject]@{
            Resource = $resource.DisplayName;
            PrincipalId = $PrincipalId
            Id = $grant.ObjectId
            Scope = $grant.Scope
        }
        $count++
    }

    # Output App Roles
    $GrantList | Sort-Object Resource | Format-List

    if ($count -eq 0) {
        Write-Host "None"
        Write-Host ""
        return
    }

    Write-Host "To remove a OAuth2 permission grant... (Example)"
    $ExampleId = $GrantList[0].Id
    Write-Host "Remove-AzureADOAuth2PermissionGrant -ObjectId $ExampleId"
    Write-Host ""
    
}


function Get-AadServicePrincipalKeyVaultAccess {
    # THIS FUNCTION IS STANDALONE
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $ObjectId
    )

    $subscriptions = Get-AzSubscription -TenantId $Global:AadSupport.Session.TenantId

    $Policies = @()

    $count = 0
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            Write-Verbose "Checking Subscription '$($sub.Name) (Id:$($sub.id))'  "
            Set-AzContext -SubscriptionId $sub.id | Out-Null
            $KeyVaults = Get-AzKeyVault
            foreach($KeyVaultItem in $KeyVaults)
            {
                $KeyVaultName = $KeyVaultItem.VaultName
                Write-Verbose "Checking Key Vault '$KeyVaultName'"
                $kv = Get-AzKeyVault -VaultName $KeyVaultName
                foreach($policy in $kv.AccessPolicies)
                {
                    if($policy.ObjectId -eq $ObjectId)
                    {
                        $CustomResult = [ordered]@{}
                        $CustomResult.KeyVaultName = $KeyVaultName
                        $CustomResult.PermissionsToSecrets = $policy.PermissionsToSecrets
                        $CustomResult.PermissionsToKeys = $policy.PermissionsToKeys
                        $CustomResult.PermissionsToCertificates = $policy.PermissionsToCertificates
                        $CustomResult.PermissionsToStorage = $policy.PermissionsToStorage
                        
                        Write-ObjectToHost $CustomResult
                        $count++
                    }
                }

                if ($count -eq 0) {
                    Write-Host "None"
                    Write-Host ""
                }

                $count = 0
            }
        }
    }
}



function Get-AadServicePrincipalAzureRoles {
    # THIS FUNCTION IS STANDALONE
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    $subscriptions = Get-AzSubscription -TenantId $Global:AadSupport.Session.TenantId

    $Count = 0
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            Write-Verbose "Checking Subscription '$($sub.Name) (Id:$($sub.id))'  "
            Set-AzContext -SubscriptionId $sub.id | Out-Null

            # Get Role Assignments
            $RoleAssignments = Get-AzRoleAssignment -ServicePrincipalName $Id

            # If Role Assignment > Write to screen
            if($RoleAssignments)
            {
                foreach($Role in $RoleAssignments)
                {
                    $CustomResult = [ordered]@{}
                    $CustomResult.Scope = $Role.Scope
                    $CustomResult.RoleName = $Role.RoleDefinitionName
    
                    Write-ObjectToHost $CustomResult 
                }
                
                $Count++
            }
        }
    }

    if($Count = 0)
    {
        Write-Host "None"
        Write-Host ""
    }

    return
}