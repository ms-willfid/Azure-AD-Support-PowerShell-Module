<#
.SYNOPSIS
    Get a list of consented permissions based using the specified parameters to filter

.DESCRIPTION
    Revokes a consented permission based on the parameters provided to be used as a filter. At minimum, the ClientId is required.

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
    Example 1: Remove all consented permissions for a app (Removes All Admin and User Consents)
    PS C:\> Revoke-AadConsent -ClientId 'Contoso App'

.EXAMPLE
    Example 2: Remove all user consented permissions leaving only the Admin consented permissions
    PS C:\> Revoke-AadConsent -ClientId 'Contoso App' -ConsentType User

.EXAMPLE
    Example 3: Revoke a specific permission
    PS C:\> Revoke-AadConsent -ClientId 'Contoso App' -ResourceId 'Microsoft Graph' -ClaimValue Directory.ReadWrite.All

.EXAMPLE
    Example 4: Revoke a specific user
    PS C:\> Revoke-AadConsent -ClientId 'Contoso App' -UserId 'john@contoso.com'

#>

function Revoke-AadConsent {
    [CmdletBinding(DefaultParameterSetName="All")] 
    param (
        [Parameter(mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$ClientId,
        [string]$ResourceId,
        [string]$ClaimValue,

        [Parameter(ParameterSetName = 'UserId')]
        [string]$UserId,

        [Parameter(ParameterSetName = 'UserConsentOnly')]
        [switch]$UserConsentOnly,

        [Parameter(ParameterSetName = 'AdminConsentOnly')]
        [switch]$AdminConsentOnly,

        [Parameter(ParameterSetName = 'ApplicationOnly')]
        [switch]$ApplicationOnly,

        [Parameter(ParameterSetName = 'DelegatedOnly')]
        [switch]$DelegatedOnly,

        [ValidateSet('Admin','User', 'All')]
        $ConsentType = 'All',

        [ValidateSet('Delegated','Application', 'All')]
        $PermissionType = 'All'
    )

    # Parameter validations
    if($ApplicationOnly -and $DelegatedOnly)
    {
        throw "You can only use one 'ApplicationOnly' or 'DelegatedOnly'"
    }

    if($ClaimValue -and -not $ResourceId)
    {
        throw "You must provide a 'ResoureId' when using 'ClaimValue'"
    }


    $TenantDomain = $Global:AadSupport.Session.TenantDomain

    # --------------------------------------------------
    # Check if signed in user is Global Admin (As only global admins can perform admin consent)
    $isGlobalAdmin = Invoke-AadCommand -Command {
        $SignedInUser = Get-AzureAdUser -ObjectId $Global:AadSupport.Session.AccountId
        $SignedInUserObjectId = $SignedInUser.ObjectId
        $GlobalAdminRoleId = (Get-AzureAdDirectoryRole | where { $_.displayName -eq 'Company Administrator' -or $_.displayName -eq 'Application Administrator' }).ObjectId
        $isGlobalAdmin = (Get-AzureAdDirectoryRoleMember -ObjectId $GlobalAdminRoleId).ObjectId -contains $SignedInUserObjectId
        return $isGlobalAdmin
    } -Parameters $Global:AadSupport.Session.AccountId
    

    if (-not $isGlobalAdmin)  
    {  
        Write-Host "Your account '$authUserId' is not a Global Admin in $TenantDomain."
        throw "Exception: 'Company Administrator' or 'Application Administrator' role REQUIRED"
    } 
    
    $CountRemovedPermissions = 0
    foreach($Permission in $ConsentedPermissions)
    {
        Show-AadSupportStatusBar
        $MsGraphUrl = "https://graph.microsoft.com/beta/oauth2PermissionGrants/$($Permission.Id)"

        if($Permission.PermissionType -eq "Delegated")
        {
            $RemoveConsent = $true

            if($ClaimValue -and $Permission.ClaimValue -ne $ClaimValue) {
                $RemoveConsent = $false
            }

            # Remove the OAuth2PermissionGrant Object
            if($RemoveConsent)
            {
                $CountRemovedPermissions++
                Invoke-AadProtectedApi `
                -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
                -Resource $Global:AadSupport.Resources.MsGraph `
                -Endpoint $MsGraphUrl -Method DELETE `
            } 

            # Update the OAuth2PermissionGrant Object to remove ClaimValue
            else {
                $CountRemovedPermissions++
                $ClaimValues = $Permission.ClaimValue.Split(" ")
                $ClaimValues = $ClaimValues | where-object {$_ -ne $ClaimValue}
                $NewClaimValues = $ClaimValues -Join " "

                
                $JsonBody = @{
                    scope = $NewClaimValues
                } | ConvertTo-Json -Compress
             
                Invoke-AadProtectedApi `
                -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
                -Resource $Global:AadSupport.Resources.MsGraph `
                -Endpoint $MsGraphUrl -Method PATCH `
                -Body $JsonBody
            }


        }

        if($Permission.PermissionType -eq "Application")
        {
            $CountRemovedPermissions++
            Invoke-AadCommand -Command {
                Param($Params)
                Remove-AzureADServiceAppRoleAssignment -ObjectId $Params.ObjectId -AppRoleAssignmentId $Params.AppRoleAssignmentId
            } -Parameters @{
                ObjectId = $Permission.ClientId
                AppRoleAssignmentId = $Permission.Id
            }
        }
    } 
    
    Write-Host "Removed $CountRemovedPermissions permission(s)"
}


function Test-RevokeAadConsent
{
    Remove-Module AadSupportPreview
    Import-Module AadSupportPreview
    Connect-AadSupport

    Set-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -Scopes 'User.read' -UserId testuser@williamfiddes.onmicrosoft.com
    Set-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -Scopes 'User.read' -UserId testuser2@williamfiddes.onmicrosoft.com

    Revoke-AadConsent -ClientId 'AadSupport UnitTest'
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ConsentType User
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -UserId testuser@williamfiddes.onmicrosoft.com
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ConsentType Admin
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -PermissionType Delegated
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -PermissionType Application

    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph'
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -UserConsentOnly 
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -UserId testuser@williamfiddes.onmicrosoft.com
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -AdminConsentOnly
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -DelegatedOnly
    Revoke-AadConsent -ClientId 'AadSupport UnitTest' -ResourceId 'Microsoft Graph' -ApplicationOnly

    
}