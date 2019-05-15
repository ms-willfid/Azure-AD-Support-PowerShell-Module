<#
.SYNOPSIS
Intelligence to return the service principal object by looking up using any of its identifiers.

.DESCRIPTION
Intelligence to return the service principal object by looking up using any of its identifiers.

.PARAMETER Id
Either specify Service Principal (SP) Name, SP Display Name, SP Object ID, Application/Client ID, or Application Object ID

.EXAMPLE
Get-AadServicePrincipal -Id 'Contoso Web App'

.NOTES
Returns the Service Pricpal object using Get-AzureAdServicePradmin@wiincipal and filter based on the Id parameter
#>

Set-Alias -Name Get-AadSp -Value Get-AadServicePrincipal

function Get-AadServicePrincipal
{
    [CmdletBinding(DefaultParameterSetName='ByAnyId')]
    param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true,
            ParameterSetName = 'ByAnyId'
        
        )]
        $Id,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByName'
        )]
        $Name,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByAppId'
        )]
        $AppId
    )


    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION
    
    $sp         = $null
    $isGuid     = $null

    if ($AppId) {
        $sp = GetAadSpByAppId $AppId
        return $sp
    }

    if ($Name) {
        $sp = GetAadSpByName $Name
        return $sp
    }

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
    }

    # Search for app based on AppId or ObjectId
    if ($isGuid) {

        # Search for app based on ObjectId
        $sp = $null
        $sp = try { Get-AzureADObjectByObjectId -ObjectId $Id } catch {}

        if ($sp.ObjectType -eq "ServicePrincipal") {
            Write-Verbose "Service Principal found using ObjectId"
            return $sp
        }

        $appid = $Id
        if ($sp.ObjectType -eq "Application") {
            Write-Verbose "Application found! Looking for Service Principal..."
            $appid = $sp.AppId
            $sp = $null
        }

        # Search for app based on AppId
        $sp = GetAadSpByAppId -Id $appid
        if ($sp) {return $sp}

    } 
    

    # Search for app based on ServicePrincipalName or DisplayName
    if(-not $sp) {
        $sp = GetAadSpByName $Id
        if ($sp) {return $sp}
    }


    # Exit script! Service Principal Not found
    if (-not $sp) {
        throw "Azure AD Service Principal '$Id' not found!"
    }

}


function GetAadSpByName
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    $sp = Get-AzureADServicePrincipal -filter "servicePrincipalNames/any(x:x eq '$Id')"
    if ($sp) { 
        Write-Verbose "Service Principal '$Id' found using ServicePrincipalName" 
        return $sp
    }

    $sp = Get-AzureADServicePrincipal -filter "DisplayName eq '$Id'"
    if ($sp) { 
        Write-Verbose "Service Principal '$Id' found using DisplayName" 
        return $sp
    }

    return
}

function GetAadSpByAppId
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
        throw "Invalid App Id"
    }

    $sp = Get-AzureADServicePrincipal -filter "AppId eq '$Id'"
    if ($sp) { 
        Write-Verbose "Service Principal found using AppId"
        return $sp
    }

    return
}



Set-Alias -Name Get-AadSpAdmins -Value Get-AadServicePrincipalAdmins
function Get-AadServicePrincipalAdmins() {
    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION

    $roles = Get-AzureADDirectoryRole | Sort-Object DisplayName
    $servicePrincipalAdmins = $null

    $list = @()

    foreach ($role in $roles) {
        $servicePrincipalAdmins = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | where-object {$_.ObjectType -eq 'ServicePrincipal'}
        
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


<#
.SYNOPSIS
#

.DESCRIPTION
Long description

.PARAMETER Id
Parameter description

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

    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION

    $sp = Get-AadServicePrincipal -Id $Id

    Get-AadServicePrincipalAdminRoles -ObjectId $sp.ObjectId
    Get-AadServicePrincipalAppRoles -ObjectId $sp.ObjectId
    Get-AadServicePrincipalGrants -ObjectId $sp.ObjectId
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

    
    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION

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
    Write-Host "Service Principal is a member of the following Azure AD Admin Roles..." -ForegroundColor Yellow
    $AdminRoleList | Sort-Object RoleDisplayName | ft

    if ($AadAdminCount -eq 0) {
        Write-Host "None"
    }

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
Set-Alias -Name Get-AadSpAppRoles -Value Get-AadServicePrincipalAppRoles
function Get-AadServicePrincipalAppRoles {
    # THIS FUNCTION IS STANDALONE
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $ObjectId
    )

    
    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION

    $AppRoleList = @()

    $AppRoles = Get-AzureADServiceAppRoleAssignedTo -ObjectId $ObjectId
    $count = 0
    foreach ($AppRole in $AppRoles) {
        
        $resource = (Get-AzureADServicePrincipal -ObjectId $AppRole.ResourceId).AppRoles | Where-Object { $_.Id -eq $AppRole.Id }

        $AppRoleList += [PSCustomObject]@{
            ResourceDisplayName = $AppRole.ResourceDisplayName;
            ResourcePermission = $resource.Value
        }
        $count++
    }

    # Output App Roles
    Write-Host "Service Principal is a member of the following Application Roles..." -ForegroundColor Yellow
    $AppRoleList | Select-Object ResourceDisplayName, ResourcePermission | ft

    if ($count -eq 0) {
        Write-Host "None"
    }
    
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

    
    # REQUIRE AadSupport
    if($global:AadSupportModule) 
    { Connect-AadSupport }
    # END REGION

    $GrantList = @()

    $grants = Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $ObjectId
    $count = 0
    foreach ($grant in $grants) {
        
        $resource = (Get-AzureADServicePrincipal -ObjectId $grant.ResourceId)

        if ($grant.ConsentType -eq "AllPrincipals") {
            $PrincipalId = "AllPrincipals"
        }
        else {
            $PrincipalId = (Get-AzureAdUser -Id $grant.PrincipalId).UserPrincipalName
        }

        $GrantList += [PSCustomObject]@{
            Resource = $resource.DisplayName;
            PrincipalId = $PrincipalId
            Scope = $grant.Scope
        }
        $count++
    }

    # Output App Roles
    Write-Host "Service Principal has the following OAuth2 permission grants..." -ForegroundColor Yellow
    $GrantList | Sort-Object Resource | Format-Table -AutoSize

    if ($count -eq 0) {
        Write-Host "None"
    }
    
}