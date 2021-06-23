<#
.SYNOPSIS
# Resolve Admin Consent Issues

.DESCRIPTION
# Resolve Admin Consent Issues when the application registration is in a external directory and it not configured correctly.

.PARAMETER Id
Identifier for the Enterprise App (ServicePrincipal) we will be consenting to.

.PARAMETER ResourceId
Identifier for the Resource (ServicePrincipal) we will be consenting permissions to.

.PARAMETER UseMsGraph
Set permission scopes for https://graph.microsoft.com

.PARAMETER UseAadGraph
Set permission scopes for https://graph.windows.net

.PARAMETER UserId
If you set a UserId, then it will use User Consent

.PARAMETER Scopes
scope permissions

.PARAMETER Expires
Set the date when these consent scope permissions (OAuth2PermissionGrants) expire.

.EXAMPLE
Set-AadConsent -Id 'Your App Name' -Scopes 'User.Read Directory.Read.All' -UseMsGraph

Applies Admin Consent for the Microsoft Graph permissions User.Read & Directory.Read.All

.EXAMPLE
Set-AadConsent -Id 'Your App Name' -Scopes 'User.Read Directory.Read.All' -UseMsGraph -UserId john@contoso.com

Applies User Consent on user john@contoso.com for the Microsoft Graph permissions User.Read & Directory.Read.All

.EXAMPLE
Set-AadConsent -Id 'Your App Name' -Scopes 'user_impersonation' -ResourceId 'Custom Api'

You can also consent for custom API

.NOTES
General notes
#>

function Set-AadConsent {
    [CmdletBinding(DefaultParameterSetName="All")] 
    param (
        [Parameter(mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$ClientId,

        [Parameter(mandatory=$true, ParameterSetName = 'UseOtherResource')]
        [string]$ResourceId,

        [Parameter(mandatory=$true, ParameterSetName = 'UseMsGraph')]
        [switch]$UseMsGraph,

        [Parameter(mandatory=$true, ParameterSetName = 'UseAadGraph')]
        [switch]$UseAadGraph,

        [Parameter(mandatory=$false)]
        [string]$Scopes,

        [Parameter(mandatory=$false)]
        [string]$Roles,

        [string]$UserId,
        $Expires = (Get-AadDateTime -AddMonths 12)
    )


    # This CmdLet shows output
    Write-Host ""
    Write-Host "WARNING - Do not use this as a permanent solution. This is a workaround. " -ForegroundColor Yellow
    Write-Host "WARNING - Please ensure the Application registration is correctly configured." -ForegroundColor Yellow
    Write-Host "WARNING - Do not use this within your own Scipts to programmatically consent" -ForegroundColor Yellow
    Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
    Write-Host ""

    $TenantDomain = $Global:AadSupport.Session.TenantId

    # --------------------------------------------------
    # Check if signed in user is Global Admin (As only global admins can perform admin consent)
    $SignedInUser = Invoke-AadCommand -Command {
        Param($ObjectId)
        Get-AzureAdUser -ObjectId $ObjectId
    } -Parameters $Global:AadSupport.Session.AccountId
    

    $SignedInUserObjectId = $SignedInUser.ObjectId

    $AllDirectoryRoles = Invoke-AadCommand -Command {
        Get-AzureAdDirectoryRole
    }

    

    $GlobalAdminRoleId = ($AllDirectoryRoles | where { $_.displayName -eq 'Global Administrator' }).ObjectId

    $CompanyAdmins = Invoke-AadCommand -Command {
        Param($GlobalAdminRoleId)
        Get-AzureAdDirectoryRoleMember -ObjectId $GlobalAdminRoleId
    } -Parameters $GlobalAdminRoleId

    $isGlobalAdmin = ($CompanyAdmins).ObjectId -contains $SignedInUserObjectId

    if (-not $isGlobalAdmin)  
    {  
        Write-Host "Your account '$authUserId' is not a Global Admin in $TenantDomain."
        throw "Exception: GLOBAL ADMIN REQUIRED"
    } 

    # Set ConsentType
    $ConsentType = "Admin"
    if($UserId)
    {
        $ConsentType = "User"
    }

    # Require ResourceId
    if (-not $ResourceId -and -not $UseMsGraph -and -not $UseAadGraph)
    {
        $ResourceId = Read-Host -Prompt "ResourceId"
    }


    # --------------------------------------------------
    # GET SERVICE PRINCIPAL Object for app we want to udpate
    $ClientObjectId = $null

    $sp = Get-AadServicePrincipal -Id $ClientId

    if(-not $sp)
    {
        throw "'$ClientId' not found in '$TenantDomain'"
    }

    Write-Host "Enterprise App (ServicePrincipal) we will be updating" -ForegroundColor Yellow
    $sp | Select-Object DisplayName, AppId, ObjectId | Format-Table 

    if($sp.count -gt 1)
    {
        throw "'$ClientId' query returned more than one result. Please provide a unique Service Principal Identifier"
    }

    $ClientObjectId = $sp.ObjectId
    

    # ------------------------------------------------
    # GET PRINCIPAL ID
    # Get User to be used as PrincipalId (If ConsentType = User)
    $Oauth2PrincipalId = $null

    if ($ConsentType -eq "User") {
        $User = Invoke-AadCommand -Command {
            Param($UserId)
            Get-AzureADUser -ObjectId $UserId
        } -Parameters $UserId

        $Oauth2PrincipalId = ($User).ObjectId

        if (-not $Oauth2PrincipalId) {
            throw "'$UserId' does not exist in '$TenantDomain'"
        }
    }


    # ------------------------------------------------
    # GET RESOURCE ID
    $ResourceObjectId = $null

    if ($UseMsGraph) {
        $resource = Invoke-AadCommand -Command {
            Get-AadServicePrincipal -Id '00000003-0000-0000-c000-000000000000'
        }

        $ResourceObjectId = $resource.ObjectId
    }
    elseif ($UseAadGraph) {
        $resource = Invoke-AadCommand -Command {
            Get-AadServicePrincipal -Id '00000002-0000-0000-c000-000000000000'
        }

        $ResourceObjectId = $resource.ObjectId
    }
    elseif ($ResourceId) {
        $resource = (Get-AadServicePrincipal -Id $ResourceId)
        $ResourceObjectId = $resource.ObjectId
    }

    if (-not $resource) {
        throw "'$ResourceId' not found in '$TenantDomain'"
    }

    if($resource.count -gt 1)
    {
        throw "The Resource query returned more than one result. Please provide a unique Service Principal Identifier"
    }

    Write-Host "Resource we will be adding permissions from..." -ForegroundColor Yellow
    $resource | Select-Object DisplayName, AppId, ObjectId | Format-Table  


    # ------------------------------------------------
    # GET SCOPES
    # Get current OAuth2PermissionGrant for Service Principal & Resource
    $OAuth2PermissionGrant = $null
    $SpOAuth2PermissionGrants = Invoke-AadCommand -Command {
        Param($ClientObjectId)
        Get-AzureADServicePrincipalOAuth2PermissionGrant -All $true -ObjectId $ClientObjectId
    } -Parameters $ClientObjectId

    # User Consent
    if ($Oauth2PrincipalId) {
        $OAuth2PermissionGrant =  $SpOAuth2PermissionGrants | Where-Object {$_.ResourceId -eq $ResourceObjectId -and $_.PrincipalId -eq $Oauth2PrincipalId}
    
    # Admin Consent
    } else {
        $OAuth2PermissionGrant = $SpOAuth2PermissionGrants | Where-Object {$_.ResourceId -eq $ResourceObjectId -and $_.ConsentType -eq 'AllPrincipals'}
    }

    # Out-put current permission grant
    if ($OAuth2PermissionGrant) {
        Write-Host "Showing current Permission grant" -ForegroundColor Yellow
        $OAuth2PermissionGrant | Format-List -property *
    }
    else {
        Write-Host "No OAuth2PermissionGrants for $ClientId"
    }


    
    # ------------------------------------------------
    # ROLES SECTION
    if($Roles)
    {
        # ------------------------------------------------
        # GET ROLES
        $CurrentAppRoles = GetAadSpAppRoles -ClientObjectId $ClientObjectId -ResourceObjectId $ResourceObjectId
        $CurrentAppRoles | Format-List

        # ------------------------------------------------
        # REMOVE ROLES
        foreach($role in $CurrentAppRoles)
        {
            Invoke-AadCommand -Command {
                Param($Params)
                Remove-AzureADServiceAppRoleAssignment -ObjectId $Params.ObjectId -AppRoleAssignmentId $Params.AppRoleAssignmentId
            } -Parameters @{
                ObjectId = $ClientObjectId
                AppRoleAssignmentId = $role.RoleAssignedId
            }
            
        }

        # ------------------------------------------------
        # ADD ROLES

        $SortedAppRoles = $resource.AppRoles | Sort-Object Value
        $AddRoles = $Roles.Split(" ")
        foreach($role in ($AddRoles))
        {
            $RoleId = ($SortedAppRoles | where {$_.Value -eq $role}).Id 
            if($RoleId)
            {
                Invoke-AadCommand -Command {
                    Param($Params)
                    New-AzureADServiceAppRoleAssignment -ObjectId $Params.ClientObjectId -Id $Params.RoleId -ResourceId $Params.ResourceObjectId -PrincipalId $Params.ClientObjectId
                } -Parameters @{
                    ClientObjectId = $ClientObjectId
                    RoleId = $RoleId
                    ResourceObjectId = $ResourceObjectId
                }
            }
            
            else 
            {
                Write-Host "'$RoleId' not found on $($resource.DisplayName)" -ForegroundColor Yellow
            }
        }

        # ------------------------------------------------
        # VERIFY ROLES
        GetAadSpAppRoles -ClientObjectId $ClientObjectId -ResourceObjectId $ResourceObjectId | Format-List
    }
    

    # ------------------------------------------------
    # BUILD NEW PERMISSION GRANT

    #Build the permission grant
    if($Scopes -ne $null)
    {
        $newPermissionGrant = @{}
        $newPermissionGrant.Add("startTime", [System.DateTime]::UtcNow.AddMinutes(-5).ToString("o"))
        $newPermissionGrant.Add("expiryTime", $Expires)
        $newPermissionGrant.Add("scope", [string]::Join(' ', $scopes))
    
        if(!$OAuth2PermissionGrant) {
            $newPermissionGrant.Add("clientId", $ClientObjectId)
            $newPermissionGrant.Add("resourceId", $ResourceObjectId)
            if ($Oauth2PrincipalId) {
                $newPermissionGrant.Add("principalId", $Oauth2PrincipalId)
                $newPermissionGrant.Add("consentType", "Principal")
            }
            else {
                $newPermissionGrant.Add("consentType", "AllPrincipals")
            }
        }
    
        $newPermissionGrant = $newPermissionGrant | ConvertTo-Json

        # ------------------------------------------------
        # GET ACCESS TOKEN FOR AAD GRAPH
        $AccessToken = GetTokenForAadGraph

        # ------------------------------------------------
        #Create the admin permission grant via graph api
        if ($OAuth2PermissionGrant) {
            $uri = "https://graph.windows.net/$TenantDomain/oauth2PermissionGrants/$($OAuth2PermissionGrant.ObjectId)/?api-version=1.6"
            Invoke-WebRequest -Uri $uri -Headers @{ "Authorization" = "Bearer " + $AccessToken } -Method Patch -Body $newPermissionGrant -ContentType "application/json" -Verbose | Format-List -Force
        }
        else {
            $uri = "https://graph.windows.net/$TenantDomain/oauth2PermissionGrants?api-version=1.6"
            Invoke-WebRequest -Uri $uri -Headers @{ "Authorization" = "Bearer " + $AccessToken } -Method Post -Body $newPermissionGrant -ContentType "application/json" -Verbose | Format-List -Force

        }

        $AccessToken = $null
    }
    
    # ------------------------------------------------
    # VERIFY UPDATE

    Write-Host "Now showing current permission grant" -ForegroundColor Yellow
    $newOAuth2PermissionGrantResponse = Invoke-AadCommand -Command {
        Param($ClientObjectId)
        Get-AzureADServicePrincipalOAuth2PermissionGrant -All $true -ObjectId $ClientObjectId
    } -Parameters $ClientObjectId

    $newOAuth2PermissionGrant = $newOAuth2PermissionGrantResponse | where {$_.ResourceId -eq $ResourceObjectId -and $_.PrincipalId -eq $Oauth2PrincipalId}
    $newOAuth2PermissionGrant | Format-List

    if ($OAuth2PermissionGrant.scope -ne $newOAuth2PermissionGrant.scope) {
        Write-Host "SUCCESS!" -ForegroundColor Yellow
    }

    else 
    {
        Write-Host "No changes occurred!" -ForegroundColor RED
    }
}

