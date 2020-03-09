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

function Get-AadAppRolesByObject {
    param(
        [Parameter(mandatory=$true, ParameterSetName="ByServicePrincipalId")]
        $ServicePrincipalId,

        [Parameter(mandatory=$true, ParameterSetName="ByObjectId")]
        [parameter(ValueFromPipeline=$true)]
        $ObjectId,

        [Parameter(mandatory=$true, ParameterSetName="ByObjectId")]
        [parameter(ValueFromPipeline=$true)]
        [ValidateSet("User","ServicePrincipal")]
        $ObjectType,

        [Parameter(mandatory=$true, ParameterSetName="ByUserId")]
        $UserId
    )
    
    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    if($ObjectId -and -not $ObjectType)
    {
        $ObjectType = (
            Invoke-AadCommand -Command {
                Param($ObjectId)
                Get-AzureADObjectByObjectId -ObjectIds $ObjectId
            } -Parameters $ObjectId
        ).ObjectType
    }

    if($ServicePrincipalId)
    {
        $sp = (Get-AadServicePrincipal -Id $ServicePrincipalId)
        $ObjectId = $sp.ObjectId

        if($sp.count -gt 1)
        {
            throw "'$ServicePrincipalId' query returned more than one result. Please provide a unique Service Principal Identifier"
        }

        if(-not $ObjectId)
        {
            throw "'$ServicePrincipalId' not found in '$TenantDomain'"
        }

        $ObjectType = "ServicePrincipal"
    }

    $TenantDomain = $Global:AadSupport.Session.TenantDomain


    $AppRoleList = @()

    if($ObjectType -eq "ServicePrincipal")
    {
        $AppRoles = Invoke-AadCommand -Command {
            Param($ObjectId)
            Get-AzureADServiceAppRoleAssignedTo -ObjectId $ObjectId
        } -Parameters $ObjectId
    }

    if($UserId)
    {
        $User = (
            Invoke-AadCommand -Command {
                Param($UserId)
                Get-AzureADUser -ObjectId $UserId
            } -Parameters $UserId
        )

        $ObjectId = $User.ObjectId

        if(-not $ObjectId)
        {
            throw "'$UserId' not found in '$TenantDomain'"
        }

        $ObjectType = "User"
    }

    if($ObjectType -eq "User")
    {
        $AppRoles = Invoke-AadCommand -Command {
            Param($ObjectId)
            Get-AzureADUserAppRoleAssignment -ObjectId $ObjectId
        } -Parameters $ObjectId
    }


    foreach ($AppRole in $AppRoles) {
        if($ObjectId -eq $AppRole.PrincipalId)
        {
            $DirectAssignment = $true
        }
        else {
            $DirectAssignment = $false
            $GetsAssignmentBy = "$($AppRole.PrincipalDisplayName) ($($AppRole.PrincipalId))"
        }

        $resource = (
            Invoke-AadCommand -Command {
                Param($AppRole)
                Get-AzureADServicePrincipal -ObjectId $AppRole.ResourceId
            } -Parameters $AppRole
        ).AppRoles | Where-Object { $_.Id -eq $AppRole.Id }

        $AppRoleList += [PSCustomObject]@{
            ResourceDisplayName = $AppRole.ResourceDisplayName;
            ResourcePermission = $resource.Value
            DirectAssignment = $DirectAssignment
            GetsAssignmentBy = $GetsAssignmentBy
            Id = $AppRole.PrincipalId   
        }
    }

    # Output App Roles

    return $AppRoleList
}