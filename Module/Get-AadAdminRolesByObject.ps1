<#
.SYNOPSIS
Gets the admin roles assigned to the specified object (User or ServicePrincipal)

.DESCRIPTION
Gets the admin roles assigned to the specified object (User or ServicePrincipal)

Example 1: Get Admin Roles for a User or Object based on its ObjectId
Get-AadAdminRolesByObject -ObjectId 

Example 2: Get Admin Roles for a ServicePrincipal
Get-AadAdminRolesByObject -ServicePrincipalId 'Contoso Web App'

Example 3: Get Admin Roles for a user
Get-AadAdminRolesByObject -UserId 'john@contoso.com'

.PARAMETER ObjectId
Lookup user or service principal by its ObjectId

.PARAMETER ServicePrincipalId
Lookup service principal by any of its Ids (DisplayName, AppId, ObjectId, or SPN)

.PARAMETER UserId
Lookup user by any of its Ids ObjectId or UserPrincipalName

.NOTES
General notes
#>

function Get-AadAdminRolesByObject {

    param(
        [Parameter(
            ValueFromPipeline = $true,
            ParameterSetName = "ByObjectId")]
        [parameter(ValueFromPipeline=$true)]
        $ObjectId,

        [Parameter(ParameterSetName = "ByServicePrincipalId")]
        $ServicePrincipalId,

        [Parameter(ParameterSetName = "ByUserId")]
        $UserId
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    # Search for ServicePrincipal
    if($ServicePrincipalId)
    {
        $sp = Get-AadServicePrincipal -Id $ServicePrincipalId

        If(-not $sp)
        {
           return 
        }

        $ObjectId = $sp.ObjectId
    }

    # Search for User
    if($UserId)
    {
        $user = Get-AzureADUser -ObjectId $UserId

        If(-not $user)
        {
           return 
        }

        $ObjectId = $user.ObjectId
    }

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
            }
        } 
    }

    # Output Admin Roles
    $ReturnObject = $AdminRoleList | Select-Object RoleDisplayName, RoleId

    return $ReturnObject

}