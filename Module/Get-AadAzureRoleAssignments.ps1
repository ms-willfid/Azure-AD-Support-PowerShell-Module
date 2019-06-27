function Get-AadAzureRoleAssignments {
    # THIS FUNCTION IS STANDALONE
    [CmdletBinding(DefaultParameterSetName="ByObject")]
    param(
        [Parameter(ParameterSetName="ByObject",Mandatory=$true)]
        [Parameter(ParameterSetName="ByServicePrincipalObject",Mandatory=$true)]
        [parameter(ValueFromPipeline=$true)]
        [string]$ObjectId,

        [Parameter(ParameterSetName="ByObject")]
        [Parameter(ParameterSetName="ByServicePrincipalObject",Mandatory=$false)]
        [parameter(ValueFromPipeline=$true)]
        [string]$ObjectType,

        [Parameter(ParameterSetName="ByServicePrincipalId",Mandatory=$true)]
        [string]$ServicePrincipalId,

        [Parameter(ParameterSetName="ByUserId",Mandatory=$true)]
        [string]$UserId,

        [Parameter(ParameterSetName="ByServicePrincipalName",Mandatory=$true)]
        [Parameter(ParameterSetName="ByServicePrincipalObject",Mandatory=$false)]
        [string]$ServicePrincipalName,

        [Parameter(ParameterSetName="BySigninName",Mandatory=$true)]
        [string]$SigninName
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $TenantDomain = $Global:AadSupport.Session.TenantId

    # If ObjectId is used, need to determine what object type it is and set appropraite variables
    if($ObjectId -and (-not $ObjectType -or $ServicePrincipalName))
    {
        $Object = Get-AzureADObjectByObjectId -ObjectIds $ObjectId

        # If no object found throw error
        if(-not $Object)
        {
            throw "'$ObjectId' not found in '$TenantDomain'"
        }
    }
    elseif($ServicePrincipalName)
    {
        $Object = Get-AadServicePrincipal -ServicePrincipalName $ServicePrincipalName
    }

    if(-not $ObjectType)
    {
        # Get Object Type
        $ObjectType = $Object.ObjectType
        if ($ObjectType -eq "ServicePrincipal")
        {
            $ServicePrincipalName = $Object.ServicePrincipalNames[0]
        }

        if ($ObjectType -eq "User")
        {
            $SigninName = $Object.UserPrincipalName
        }
    }


    if($ServicePrincipalId)
    {
        $sp = (Get-AadServicePrincipal -Id $ServicePrincipalId)
        $ServicePrincipalName = $sp.ServicePrincipalNames[0]
        $ObjectId = $sp.ObjectId

        if($sp.count -gt 1)
        {
            throw "'$ServicePrincipalId' query returned more than one result. Please provide a unique Service Principal Identifier"
        }

        if(-not $ServicePrincipalName)
        {
            throw "'$ServicePrincipalId' not found in '$TenantDomain'"
        }
    }

    if($UserId)
    {
        $User = (Get-AzureADUser -ObjectId $UserId)
        $SigninName = $User.UserPrincipalName

        if(-not $UserId)
        {
            throw "'$UserId' not found in '$TenantDomain'"
        }
    }

    $subscriptions = Get-AzSubscription -TenantId $Global:AadSupport.Session.TenantId

    $result = @()
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            Write-Verbose "Checking Subscription '$($sub.Name) (Id:$($sub.id))'"
            Select-AzSubscription -SubscriptionId $sub.id | Out-Null

            # Get Role Assignments
            if($ServicePrincipalName)
            {
                $RoleAssignments = @()

                # Get Direct Assignments
                $RoleAssignments += Get-AzRoleAssignment -ServicePrincipalName $ServicePrincipalName

                # Get groups assigned to Azure RBAC (we need to check each group)
                $GroupIdsCheck = (Get-AzRoleAssignment | where {$_.ObjectType -eq "Group"}).ObjectId

                $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
                $Groups.GroupIds = $GroupIdsCheck

                # Check if ServicePrincipal is a member of any of those groups
                $IsMemberOf = Select-AzureADGroupIdsServicePrincipalIsMemberOf -ObjectId $ObjectId -GroupIdsForMembershipCheck $Groups

                # Get Azure RBAC for the groups in which the Service Principal is a member of
                foreach($GroupId in $IsMemberOf)
                {
                    $RoleAssignments += Get-AzRoleAssignment -ObjectId $GroupId
                }
                
                
            }

            if($SigninName)
            {
                $RoleAssignments = Get-AzRoleAssignment -SignInName $SigninName -ExpandPrincipalGroups
            }
            
            if($IsMemberOf)
            {
                $DirectAssignment = $false
            }
            else {
                $DirectAssignment = $true
            }

            # If Role Assignment > generate output
            if($RoleAssignments)
            {
                foreach($Role in $RoleAssignments)
                {
                    if($IsMemberOf)
                    {
                        $AssignedDisplayName = (Get-AzureADObjectByObjectId -ObjectIds $Role.ObjectId).DisplayName
                        $GetsAssignmentBy = "$($AssignedDisplayName) ($($Role.ObjectId))"
                    }

                    $Split = $Role.Scope.Split("/")
                    $CustomResult = [pscustomobject]@{
                        Scope = $Role.Scope;
                        RoleName = $Role.RoleDefinitionName;
                        ResourceName = $Split[$Split.Lenth-1];
                        DirectAssignment = $DirectAssignment
                        GetsAssignmentBy = $GetsAssignmentBy;
                    }
    
                    $result += $CustomResult 
                }
            }
        }
    }

    return $result
}