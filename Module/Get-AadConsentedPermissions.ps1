<#
.SYNOPSIS
Gets the OAuth2PermissionGrants (Consented Permissions) assigned to the specified object (User or ServicePrincipal)

.DESCRIPTION
Gets the OAuth2PermissionGrants (Consented Permissions) assigned to the specified object (User or ServicePrincipal)

# Example 1: Get OAuth2PermissionGrants for a User or Object based on its ObjectId
Get-AadConsentedPermissions -ObjectId 564f76ca-a8c5-4b25-a5d3-853ceba34677
Get-AadConsentedPermissions -ObjectId 564f76ca-a8c5-4b25-a5d3-853ceba34677 -ObjectType User
Get-AadConsentedPermissions -ObjectId 516125ca-0f5e-46b7-9189-5ff14108ece2 -ObjectType ServicePrincipal

Note: When specifing ObjectType, it will not make another call to Azure AD to get the object

# Use these other examples if the ObjectId is not known.
# Example 2: Get OAuth2PermissionGrants for a ServicePrincipal
Get-AadConsentedPermissions -ServicePrincipalId 'Contoso Web App'

# Example 3: Get OAuth2PermissionGrants for a user
Get-AadConsentedPermissions -UserId 'john@contoso.com'

.PARAMETER ObjectId
Lookup user or service principal by its ObjectId

.PARAMETER ObjectType
When ObjectId is used, this is required to let us know if this is a user or serviceprincipal

.PARAMETER ServicePrincipalId
Lookup service principal by any of its Ids (DisplayName, AppId, ObjectId, or SPN)

.PARAMETER UserId
Lookup user by any of its Ids ObjectId or UserPrincipalName

.NOTES
General notes
#>

function Get-AadConsentedPermissions {

    param(
        # When ObjectId and ObjectType are used together, we will not perform additional queries to find the object
        [Parameter(ParameterSetName = "ByObjectId", Mandatory=$true)]
        [parameter(ValueFromPipeline=$true)]
        [string]$ObjectId,

        [Parameter(ParameterSetName = "ByObjectId")]
        [parameter(ValueFromPipeline=$true)]
        [ValidateSet("User","ServicePrincipal")]
        [string]$ObjectType,

        # When ServicePrincipal is used, we will perform additional query to lookup the ServicePrincipal
        [Parameter(ParameterSetName = "ByServicePrincipalId", Mandatory=$true)]
        [string]$ServicePrincipalId,

        # When UserId is used, we will perform additional query to lookup the User
        [Parameter(ParameterSetName = "ByUserId", Mandatory=$true)]
        [string]$UserId
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $Grants = $null

    if($ObjectId -and -not $ObjectType)
    {
        $ObjectType = (Get-AzureADObjectByObjectId -ObjectIds $ObjectId).ObjectType
    }

    # Get Consented Permissions (OAuth2PermissionsGrants) for ServicePrincipal
    if($ServicePrincipalId -or $ObjectType -eq "ServicePrincipal")
    {

        if($ServicePrincipalId)
        {
            $sp = Get-AadServicePrincipal -Id $ServicePrincipalId

            If(-not $sp)
            {
                return 
            }

            $ObjectId = $sp.ObjectId
        }
        
        $Grants = Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $ObjectId
    }

    # Get Consented Permissions (OAuth2PermissionsGrants) for User
    if($UserId -or $ObjectType -eq "User")
    {
        if($UserId)
        {
            $user = Get-AzureADUser -ObjectId $UserId

            If(-not $user)
            {
               return 
            }
    
            $ObjectId = $user.ObjectId
        }

        $Grants = Get-AzureADUserOAuth2PermissionGrant -ObjectId $ObjectId
    }

    $GrantList = @()

    foreach ($grant in $grants) {
        
        $resource = (Get-AzureADServicePrincipal -ObjectId $grant.ResourceId)
        $client = (Get-AzureADServicePrincipal -ObjectId $grant.ClientId)

        # Admin Consent
        if ($grant.ConsentType -eq "AllPrincipals") {
            $PrincipalId = "AllPrincipals"
        }

        # User Consent
        else {
            $PrincipalId = (Get-AzureAdUser -ObjectId $grant.PrincipalId).UserPrincipalName
        }

        # Add Consented Permission to Array
        $GrantList += [PSCustomObject]@{
            ClientName = $client.DisplayName;
            ResourceName = $resource.DisplayName;
            PrincipalId = $PrincipalId;
            Id = $grant.ObjectId;
            Scope = $grant.Scope
        }
    }

    # Return Consented Permissions
    $return = $GrantList | Sort-Object ClientName, ResourceName
    return $return
}