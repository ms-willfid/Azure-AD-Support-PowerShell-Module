<#
.SYNOPSIS
Manually consent to permissions

.DESCRIPTION
Manually consent to permissions. This works for Admin consent, user consent, delegated permissions, and application permissions.

EXAMPLES
# Add Admin Consent for a Delegated Permission
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Delegated -ClaimValue User.Read

# Add User Consent for single user (new OAuth2PermissionGrant)
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Delegated -ClaimValue User.Read -UserId john@contoso.com

# Update User Consent for all users (existing OAuth2PermissionGrant)
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -ConsentType User -PermissionType Delegated -ClaimValue Directory.AccessAsUser.All

# Add Admin Consent for Application Permission
Add-AadConsent -ClientId b330d711-77c4-463b-a391-6b3fbef74ffd -ResourceId "Microsoft Graph" -PermissionType Application -ClaimValue User.Read.All


.PARAMETER ClientId
Identifier for the Enterprise App (ServicePrincipal) we will be consenting to.

.PARAMETER ResourceId
Identifier for the Resource (ServicePrincipal) we will be consenting permissions to.

.PARAMETER UserId
If you set a UserId, then it will use User Consent

.PARAMETER ClaimValue
This is the permission you want to add. We also accept multiple values here as space delimitted list.

.PARAMETER ConsentType
Specify if this is a 'Admin' consent or 'User' consent
Default value if none is specified is 'Admin'

.PARAMETER PermissionType
Specify if this is a 'Delegated' permission or 'Application' permission

.NOTES
General notes
#>
function Add-AadConsent {
    [CmdletBinding(DefaultParameterSetName="DefaultSet")] 
    param (
        [Parameter(mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$ClientId,

        [Parameter(mandatory=$true)]
        [string]$ResourceId,

        [Parameter(mandatory=$true)]
        [string]$ClaimValue,

        [Parameter(mandatory=$false)]
        [ValidateSet('Admin','User')]
        $ConsentType="Admin",

        [Parameter(mandatory=$false)]
        [ValidateSet('Delegated','Application')]
        $PermissionType="Delegated",

        [string]$UserId
    )

    #Required but ignored parameter
    $Expires = (Get-AadDateTime -AddMonths 12)

    # Parameter validations
    if($UserId)
    {
        $ConsentType = "User"
    }

    if($UserId -and $PermissionType -eq "Application")
    {
        throw "You can't provide a UserId and set PermissionType to 'Application'"
    }

    $TenantDomain = $Global:AadSupport.Session.TenantId

    # --------------------------------------------------
    # Check if signed in user is Global Admin (As only global admins can perform admin consent)
    $isGlobalAdmin = Invoke-AadCommand -Command {
        Param(
            $AccountId
        )
        $SignedInUser = Get-AzureAdUser -ObjectId $AccountId
        $SignedInUserObjectId = $SignedInUser.ObjectId
        $GlobalAdminRoleIds = (Get-AzureAdDirectoryRole | where { $_.displayName -eq 'Company Administrator' -or $_.displayName -eq 'Application Administrator' }).ObjectId
        
        foreach($GlobalAdminRoleId in $GlobalAdminRoleIds)
        {
            if( (Get-AzureAdDirectoryRoleMember -ObjectId $GlobalAdminRoleId).ObjectId -contains $SignedInUserObjectId )
            {
                return $true
            }
        }
        
        
    } -Parameters $Global:AadSupport.Session.AccountId
    

    if (-not $isGlobalAdmin)  
    {  
        Write-Host "Your account '$($Global:AadSupport.Session.AccountId)' is not a Global Admin in $TenantDomain."
        throw "Exception: 'Company Administrator' or 'Application Administrator' role REQUIRED\r\n * Application Administrator can only perform consent for delegated permissions"
    } 

    # ++++++++++++++++++++++++
    # GET CLIENT ID
    # ++++++++++++++++++++++++
    $Client = $null

    $client = Get-AadServicePrincipal -Id $ClientId
    $ClientId = $client.ObjectId
    Write-Verbose "ClientId: $ClientId"

    # ++++++++++++++++++++++++
    # GET RESOURCE ID
    # ++++++++++++++++++++++++
    $Resource = $null

    $resource =  Get-AadServicePrincipal -Id $ResourceId
    

    $ResourceId = $resource.ObjectId
    Write-Verbose "ResourceId: $ResourceId"

    # ++++++++++++++++++++++++
    # GET PRINCIPAL ID
    # ++++++++++++++++++++++++
    $User = $null
    $PrincipalId = $null
    if($UserId)
    {
        $User = Invoke-AadCommand -Command {
            Param($UserId)
            Get-AzureADUser -ObjectId $UserId
        } -Parameters $UserId
    
        $PrincipalId = ($User).ObjectId
    
        if (-not $PrincipalId) {
            throw "'$UserId' does not exist in '$TenantDomain'"
        }
    }
    Write-Verbose "PrincipalId: $PrincipalId"

    # START
    $RequestedPermissions = $ClaimValue.Split(" ").Split(";").Split(",")

    $ConsentedPermissions = $null
    
    if($PermissionType -eq "Delegated")
    {
        # Check if OAuth2PermissionGrant already exists
        if(!$ConsentedPermissions)
        {
            $ConsentedPermissions = Get-AadConsent `
            -ClientId $ClientId `
            -ResourceId $ResourceId `
            -ConsentType $ConsentType `
            -PermissionType $PermissionType `
            -UserId $PrincipalId
        }

        Write-Verbose "Showing Consented Permissions..."
        if($ConsentedPermissions)
        {
            Write-Verbose ($ConsentedPermissions|ConvertTo-Json)
        }
        else
        {
            Write-Verbose "NONE."
        }
        

        foreach($RequestedPermission in $RequestedPermissions)
        {
            Write-Verbose "Checking RequestedPermission $RequestedPermission"

            # Oauth2PermissionGrant exists.
            # Lets go update it.
            if($ConsentedPermissions)
            {
                foreach($Permission in $ConsentedPermissions)
                {
                    Write-Verbose "Checking ConsentedPermission $($Permission.ClaimValue)"

                    if($Permission.ClaimValue)
                    {
                        $CurrentScopes = $Permission.ClaimValue.Split(" ")
                    }
                    else
                    {
                        $CurrentScopes = ""
                    }
                    
                    # Skip of Permission is already there
                    if($CurrentScopes -contains $RequestedPermission)
                    {
                        Write-Host "$RequestedPermission already exists on OAuth2PermissinGrant $($Permission.Id)"
                        continue
                    }

                    $NewScopes += $CurrentScopes 
                    $NewScopes += $RequestedPermission

                    $MsGraphUrl = "$($Global:AadSupport.Resources.MsGraph)/beta/oauth2PermissionGrants/$($Permission.Id)"
 
                    $JsonBody = @{
                        scope = [string]::Join(' ', $NewScopes)
                    } | ConvertTo-Json -Compress

                    Write-Verbose "JsonBody..."
                    Write-Verbose $JsonBody

                    Write-Verbose "Updating existing OAuth2PermissionGrant"

                    Invoke-AadProtectedApi `
                    -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
                    -Resource $Global:AadSupport.Resources.MsGraph `
                    -Endpoint $MsGraphUrl -Method PATCH `
                    -Body $JsonBody
                } 
            }
    
            # Oauth2PermissionGrant does not exist.
            # Lets go create one.
            else
            {
                # Lets start building the OAuth2PermissionGrant
                $newPermissionGrant = @{}
                $newPermissionGrant.Add("startTime", [System.DateTime]::UtcNow.AddMinutes(-5).ToString("o"))
                $newPermissionGrant.Add("expiryTime", $Expires)
                $newPermissionGrant.Add("clientId", $ClientId)
                $newPermissionGrant.Add("resourceId", $ResourceId)
                $newPermissionGrant.Add("scope", $ClaimValue)
                if ($PrincipalId) {
                    $newPermissionGrant.Add("principalId", $PrincipalId)
                    $newPermissionGrant.Add("consentType", "Principal")
                }
                else {
                    $newPermissionGrant.Add("consentType", "AllPrincipals")
                }

                $MsGraphUrl = "$($Global:AadSupport.Resources.MsGraph)/beta/oauth2PermissionGrants"
                
                $JsonBody = $newPermissionGrant | ConvertTo-Json -Compress

                Write-Verbose "JsonBody..."
                Write-Verbose $JsonBody

                Write-Verbose "Adding OAuth2PermissionGrant"

                Invoke-AadProtectedApi `
                        -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
                        -Resource $Global:AadSupport.Resources.MsGraph `
                        -Endpoint $MsGraphUrl -Method POST `
                        -Body $JsonBody
            }
    
            
            
        }
    }
    
    
    if($PermissionType -eq "Application")
    {
        foreach($RequestedPermission in $RequestedPermissions)
        {
            $ConsentedPermissions = Get-AadConsent `
            -ClientId $ClientId `
            -ResourceId $ResourceId `
            -PermissionType $PermissionType `
            -ClaimValue $RequestedPermission
    
            if($ConsentedPermissions)
            {
                Write-Host "$RequestedPermission already exists!"
                continue
            }
    
            else
            {
                # ------------------------------------------------
                # ADD ROLES (App Role Assignment)
    
                $AppRoles = $resource.AppRoles | Sort-Object Value
                
                # Get the Role ID
                $RoleId = ($AppRoles | where {$_.Value -eq $RequestedPermission}).Id 

                if($RoleId)
                {
                    Write-Verbose "Adding AppRole assignment"

                    Invoke-AadCommand -Command {
                        Param($Params)
                        New-AzureADServiceAppRoleAssignment -ObjectId $Params.ClientObjectId -Id $Params.RoleId -ResourceId $Params.ResourceObjectId -PrincipalId $Params.ClientObjectId
                    } -Parameters @{
                        ClientObjectId = $ClientId
                        RoleId = $RoleId
                        ResourceObjectId = $ResourceId
                    }
                }
                
                else 
                {
                    Write-Host "'$RoleId' not found on $($resource.DisplayName)" -ForegroundColor Yellow
                }
                
            }
        }
    }
}