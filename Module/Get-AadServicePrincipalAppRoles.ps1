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
Set-Alias -Name Get-AadSpAppRoles -Value Get-AadServicePrincipalAppRoles
function Get-AadServicePrincipalAppRoles {
    # THIS FUNCTION IS STANDALONE
    param(
        [Parameter(mandatory=$true, Position=0, ParameterSetName="ByAnyId")]
        $Id,

        [Parameter(mandatory=$true, ParameterSetName="ByObjectId")]
        $ObjectId
    )
    
    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $TenantDomain = $Global:AadSupport.Session.TenantDomain

    $AppRoleList = @()

    if($Id)
    {
        $sp = (Get-AadServicePrincipal -Id $Id)
        $ObjectId = $sp.ObjectId
    }

    if(-not $sp)
    {
        throw "'$Id' not found in '$TenantDomain'"
    }


    if($sp.count -gt 1)
    {
        throw "'$Id' query returned more than one result. Please provide a unique Service Principal Identifier"
    }


    $AppRoles = Get-AzureADServiceAppRoleAssignedTo -ObjectId $ObjectId
    $count = 0
    foreach ($AppRole in $AppRoles) {
        
        $resource = (Get-AzureADServicePrincipal -ObjectId $AppRole.ResourceId).AppRoles | Where-Object { $_.Id -eq $AppRole.Id }

        $AppRoleList += [PSCustomObject]@{
            ResourceDisplayName = $AppRole.ResourceDisplayName;
            ResourcePermission = $resource.Value
            Id = $AppRole.ObjectId
            
        }
        $count++
    }

    # Output App Roles
    $AppRoleList | Format-Table ResourceDisplayName, ResourcePermission, Id

    if ($count -eq 0) {
        Write-Host "None"
        Write-Host ""
        return
    }
    
    Write-Host "To remove a App Role... (Example)"
    $ExampleId = $AppRoleList[0].Id
    Write-Host "Remove-AzureADServiceAppRoleAssignment -ObjectId $ObjectId -AppRoleAssignmentId $ExampleId"
    Write-Host ""
}