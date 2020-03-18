
<#
.SYNOPSIS
Gets a list of Service Principals assigned to a Administrator role in Azure AD

.DESCRIPTION
Gets a list of Service Principals assigned to a Administrator role in Azure AD

.EXAMPLE
Get-AadServicePrincipalAdmins

.NOTES
General notes
#>

function Get-AadServicePrincipalAdmins() {
    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $roles = Invoke-AadCommand -Command {
        Get-AzureADDirectoryRole | Sort-Object DisplayName
    }

    $servicePrincipalAdmins = $null

    $list = @()

    foreach ($role in $roles) {
        if($role.DisplayName -eq "Directory Readers" -or $role.DisplayName -eq "Directory Writers"){
            continue
        }

        $servicePrincipalAdmins = Invoke-AadCommand -Command {
            Param($RoleObjectId)
            Get-AzureADDirectoryRoleMember -ObjectId $RoleObjectId | where-object {$_.ObjectType -eq 'ServicePrincipal'}
        } -Parameters $role.ObjectId
        
        foreach ($sp in $servicePrincipalAdmins) {
            $item = [PSCustomObject]@{
                DisplayName = $sp.DisplayName
                Id = $sp.ObjectId
                Role = $role.DisplayName
            } 

            $list += $item
        }
    }

    Write-Host "Service Pricipals with Azure AD Admin Roles ($($list.count) Found)." -ForegroundColor Yellow
    $list | Sort-Object DisplayName, Role
}

Set-Alias -Name Get-AadSpAdmins -Value Get-AadServicePrincipalAdmins
