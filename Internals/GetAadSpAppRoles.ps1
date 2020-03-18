function GetAadSpAppRoles
{
    param(
        [string]$ClientObjectId, 
        [AllowNull()][string]$ResourceObjectId
    )

    $ServiceAppRoleAssignedTo = Invoke-AadCommand -Command {
        Param($ClientObjectId)
        Get-AzureADServiceAppRoleAssignedTo -All $true -ObjectId $ClientObjectId
    } -Parameters $ClientObjectId

    if($ResourceObjectId)
    {
        $ResourceSp = Get-AadServicePrincipal -Id $ResourceObjectId
        $CurrentAppRoles = $ServiceAppRoleAssignedTo | where {$_.ResourceId -eq $ResourceObjectId}
    }

    else 
    {
        $CurrentAppRoles = $ServiceAppRoleAssignedTo 
    }
    
        # Out-put current App Roles
        if ($CurrentAppRoles) {

            

            $AppRolesView = @()
            foreach($AppRole in $CurrentAppRoles) 
            {
                $Resource = Get-AadServicePrincipal -Id $AppRole.ResourceId

                $AppRolesView += [PSCustomObject]@{
                    RoleId = $AppRole.Id
                    RoleValue = ($Resource.AppRoles | where {$_.Id -eq $AppRole.Id}).Value 
                    RoleAssignedId = $AppRole.ObjectId
                    ResourceDisplayName = $AppRole.ResourceDisplayName 
                }
            }

            return $AppRolesView
        }

    return
}