<#
.SYNOPSIS
    Get a list of consented permissions based using the specified parameters to filter

.DESCRIPTION
    Get a list of consented permissions based using the specified parameters to filter

    Get-AadConsent Returns the following Object with properties
    PermissionType | Expected values: Role, Scope | Role if Application permission, Scope if Delegated permission
    ClientName | Name of the client
    ClientId | Service Principal Object ID of the client
    ResourceName | Name of the resource
    ResourceId  | Service Principal Object ID of the resource
    PrincipalId | Service Principal Object ID of the user
    ClaimValue | List of scopes or role claim values
    Id | Id of the OAuth2PermissionGrant/AppRole
    ConsentType | Expected values: AdminConsent, UserConsent

.PARAMETER ClientId
    Filter based on the ClientId. This is the Enterprise App (Client app) in which the consented permissions are applied on.

.PARAMETER ResourceId
    Filter based on the ResourceId. This is the resource in which the client has permissions on.

.PARAMETER UserId
    Filter based on the UserId. User in which that has consented to the app.

.PARAMETER ClaimValue
    Filter based on the scope or role value.

.PARAMETER ConsentType
    Filter based on the Consent Type. Available options...
    'Admin','User', 'All'

.PARAMETER PermissionType
    Filter based on the Permission Type. Available options...
    'Delegated','Application', 'All'

.EXAMPLE
    Example 1: See a list of all consents for a app
    PS C:\> Get-AadConsent -ClientId 'Contoso App' | Format-List

.EXAMPLE
    Example 2: See a list of User Consents for a app
    PS C:\> Get-AadConsent -ClientId 'Contoso App' -UserId john@contoso.com | Format-List
#>
function Get-AadConsent
{
    
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param(
        [string]$ClientId,
        [string]$ResourceId,
        [string]$UserId,

        [ValidateSet('Admin','User', 'All')]
        $ConsentType = 'All',

        [ValidateSet('Delegated','Application', 'All')]
        $PermissionType = 'All',

        [string]$ClaimValue
    )

    $PrincipalId = $UserId

    # Parameter Validations
    if(!$ClientId -and !$ResourceId -and !$PrincipalId)
    {
        throw "You must specify at least one of the properties : ClientId or ResourceId or PrincipalId"
    }

    if( ($Principald -and $PermissionType -eq 'Application') -or ($PermissionType -eq 'Application' -and $ConsentType -eq 'User') )
    {
        throw "You can't have PermissionType 'Application' and specify a user."
    }

    if($ClaimValue -and -not $ResourceId)
    {
        throw "You must provide a 'ResoureId' when using 'ClaimValue'"
    }

    # Start building the OAuth2PermissionGrant Filter
    $GrantFilterBuilder = @()

    if($ConsentType -eq "User" -and !$UserId)
    {
        $GrantFilterBuilder += "consentType eq 'Principal'"
    }
    elseif($ConsentType -eq "Admin")
    {
        $GrantFilterBuilder += "consentType eq 'AllPrincipals'"
    }

    $GrantUri = "$($Global:AadSupport.Resources.MsGraph)/beta/oauth2PermissionGrants?`$top=999"

    $Resource = $null
    if($ResourceId)
    {
        $Resource = Get-AadServicePrincipal -Id $ResourceId
        if(!$Resource)
        {
            throw "$ResourceId not found!"
        }

        $RoleUri = "$($Global:AadSupport.Resources.MsGraph)/beta/servicePrincipals/$($Resource.ObjectId)/appRoleAssignedTo?`$top=999"

        $GrantFilterBuilder += "resourceId eq '$($Resource.ObjectId)'"
    }


    $Client = $null
    if($ClientId)
    {
        $Client = Get-AadServicePrincipal -Id $ClientId
        if(!$Client)
        {
            throw "$ClientId not found!"
        }
        
        $RoleUri = "$($Global:AadSupport.Resources.MsGraph)/beta/servicePrincipals/$($Client.ObjectId)/appRoleAssignments?`$top=999"
        
        $GrantFilterBuilder += "clientId eq '$($Client.ObjectId)'"
    }


    $Principal = $null
    if($PrincipalId)
    {
        $Principal = Invoke-AadCommand -Command {
            Param($PrincipalId)
            Get-AzureAdUser -ObjectId $PrincipalId
        } -Parameters  $PrincipalId

        if(!$Principal)
        {
            throw "$PrincipalId not found!"
        }

        $GrantFilterBuilder += "principalId eq '$($Principal.ObjectId)'"
    }

    # CREATE FILTER FOR OAUTH2PERMISSION GRANTS
    if($GrantFilterBuilder)
    {
        $GrantFilter = "`&`$filter="
    }

    foreach($item in $GrantFilterBuilder)
    {
        if($item -ne $GrantFilterBuilder[0])
        {
            $GrantFilter += " and "
        }
        $GrantFilter += $item
    }


    # ------------------------------------------------
    # GET OAUTH2PERMISSIONGRANT

    <#
        {
            "@odata.context": "https://graph.microsoft.com/beta/$metadata#oauth2PermissionGrants",
            "value": [
                {
                    "clientId": "7f5c5913-b683-4b71-a57b-008cd3de72e5",
                    "consentType": "AllPrincipals",
                    "expiryTime": "2021-02-11T22:51:28.9886344Z",
                    "id": "E1lcf4O2cUulewCM095y5Yb6Xxl6wYJDqt2ei2ygkbw",
                    "principalId": null,
                    "resourceId": "195ffa86-c17a-4382-aadd-9e8b6ca091bc",
                    "scope": "user_impersonation",
                    "startTime": "0001-01-01T00:00:00Z"
                }
            ]
        }
    #>

    if($PermissionType -eq 'All' -or $PermissionType -eq "Delegated")
    {
        $Grants =  Invoke-AadProtectedApi `
        -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
        -Resource $Global:AadSupport.Resources.MsGraph `
        -Endpoint $GrantUri+$GrantFilter -Method "GET"
    }

    $Permissions = [PSCustomObject]@()

    if($Grants)
    {
        
        foreach($item in $Grants)
        {
            Show-AadSupportStatusBar
            # Skip condition if we only want to see UserConsent
            if($ConsentType -eq "User" -and $item.consentType -eq "AllPrincipals")
            {
                continue
            }

            # Skip condition if we only want to see AdminConsent
            if($ConsentType -eq "Admin" -and $item.consentType -eq "Principal")
            {
                continue
            }

            $Permission = @{
                PermissionType = "Delegated"
            }

            $ItemClient = $null
            if($item.clientId -and $Client.ObjectId -ne $item.clientId)
            {
                $ItemClient = Get-AadServicePrincipal -Id $item.clientId
            }
            else {
                $ItemClient = $Client
            }

            $ItemResource = $null
            if($item.resourceId -and $Resource.ObjectId -ne $item.resourceId)
            {
                $ItemResource = Get-AadServicePrincipal -Id $item.resourceId
            }
            else {
                $ItemResource = $Resource
            }

            $ItemPrincipal = $null
            if(!$item.principalId)
            {
                $Permission.ConsentType = "AdminConsent"
            }
            else {
                if($item.principalId -and $Principal.ObjectId -ne $item.principalId)
                {
                    $ItemPrincipal = Invoke-AadCommand -Command {
                        Param($PrincipalId)
                        Get-AzureAdUser -ObjectId $PrincipalId
                    } -Parameters  $item.principalId
                }
                else {
                    $ItemPrincipal = $Principal
                }

                $Permission.ConsentType = "UserConsent"
            }

            $Permission.ClientName = $ItemClient.DisplayName
            $Permission.ClientId = $ItemClient.ObjectId
            $Permission.ResourceName = $ItemResource.DisplayName
            $Permission.ResourceId = $ItemResource.ObjectId
            $Permission.PrincipalId = $ItemPrincipal.userPrincipalName
            $Permission.ClaimValue = $item.scope
            $Permission.Id = $item.id

            $PermissionObject = New-Object -TypeName 'PSObject' -Property $Permission

            $Permissions += $PermissionObject
        }
    }

    


    # ------------------------------------------------
    # GET ROLES

    # NOTE: AppRoleAssignments in MS Graph does not support filtering
    
    if(($PermissionType -eq 'All' -or $PermissionType -eq "Application") -and $ConsentType -ne 'User' -and !$PrincipalId)
    {
        $RoleAssignments =  Invoke-AadProtectedApi `
        -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
        -Resource $Global:AadSupport.Resources.MsGraph `
        -Endpoint $RoleUri -Method "GET"
    }
  
    if($RoleAssignments)
    {
        if($Client) {
            $RoleAssignments = $RoleAssignments | where-object {$_.principalId -eq $Client.ObjectId }
        }

        if($Resource) {
            $RoleAssignments = $RoleAssignments | where-object {$_.resourceId -eq $Resource.ObjectId }
        }
        
        foreach($item in $RoleAssignments) 
        {
            Show-AadSupportStatusBar
            

            $Permission = @{
                PermissionType = "Application"
            }
    
            $ItemClient = $null
            if($item.clientId -and $Client.ObjectId -ne $item.principalId)
            {
                $ItemClient = Get-AadServicePrincipal -Id $item.principalId
            }
            else {
                $ItemClient = $Client
            }
    
            $ItemResource = $null
            if($item.resourceId -and $Resource.ObjectId -ne $item.resourceId)
            {
                $ItemResource = Get-AadServicePrincipal -Id $item.resourceId
            }
            else {
                $ItemResource = $Resource
            }
    
            $Permission.ClientName = $ItemClient.DisplayName
            $Permission.ClientId = $ItemClient.ObjectId
            $Permission.ResourceName = $ItemResource.DisplayName
            $Permission.ResourceId = $ItemResource.ObjectId
            $RoleName = ($ItemResource.AppRoles | Where-Object {$_.id -eq $item.appRoleId }).Value
            $Permission.ClaimValue = $RoleName
            $Permission.Id = $item.id
            $Permission.ConsentType = "AdminConsent"
            $Permission.PrincipalId = $null
    
            $PermissionObject = New-Object -TypeName 'PSObject' -Property $Permission
    
            $Permissions += $PermissionObject
        }
    }

    if($ClaimValue)
    {
        return $Permissions | where {(" "+$_.ClaimValue+" ") -match (" "+$ClaimValue+" ")}
    }

    return $Permissions
}