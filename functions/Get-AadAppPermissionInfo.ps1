<#
.SYNOPSIS
Easily find the value or id of a permission based on the servicePrincipals AppRoles or Oauth2Permissions

.DESCRIPTION
Long descriptionEasily find the value or id of a permission based on the servicePrincipals AppRoles or Oauth2Permissions

.PARAMETER ResourceId
Provide the Resource Identifier

.PARAMETER Permission
Provide the permission you want to look up.

EXAMPLES

# Lookup Scope/Role Value
Get-AadAppPermissionInfo "Microsoft Graph" -Permission User.Read.All

# Lookup Scope Id > This is the id for User.Read Scope
Get-AadAppPermissionInfo "Microsoft Graph" -Permission a154be20-db9c-4678-8ab7-66f6cc099a59

# Lookup Role Id > This is the id for User.Read Role
Get-AadAppPermissionInfo "Microsoft Graph" -Permission df021288-bdef-4463-88db-98f22de89214

.NOTES
General notes
#>
function Get-AadAppPermissionInfo {
    [CmdletBinding(DefaultParameterSetName="DefaultSet")] 
    param (
        [Parameter(mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$ResourceId,

        [Parameter(mandatory=$true)]
        [string]$Permission
    )

    # Get the servicePrincipal for the resource
    $sp = Get-AadServicePrincipal -Id $ResourceId

    # Lookup the permission in AppRoles
    $Roles = $sp.AppRoles | where {$_.Value -eq $Permission -or $_.id -eq $Permission} | Select Id, Value, Type
    
    # Role found so add the 'Type' property
    if($Roles)
    {
        $Roles.Type = "Role"
    }

    # Lookup the permission in Oauth2Permissions
    $Scopes = $sp.Oauth2Permissions | where {$_.Value -eq $Permission -or $_.id -eq $Permission} | Select Id, Value, Type
    
    # Scope found so add the 'Type' property
    if($Scopes)
    {
        $Scopes.Type = "Scope"
    }

    # Build our results
    $results = @()
    $results += $Roles
    $results += $Scopes

    return $results
}
