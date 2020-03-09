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
        $Object = Invoke-AadCommand -Command {
            Param($ObjectId)
            Get-AzureADObjectByObjectId -ObjectIds $ObjectId
        } -Parameters $ObjectId

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
        $User = (
            Invoke-AadCommand -Command {
                Param($UserId)
                Get-AzureADUser -ObjectId $UserId
            } -Parameters $UserId
        )
        $SigninName = $User.UserPrincipalName

        if(-not $UserId)
        {
            throw "'$UserId' not found in '$TenantDomain'"
        }
    }

    $subscriptions = Invoke-AzureCommand -Command {
        Param($TenantId)
         Get-AzSubscription -TenantId $TenantId
    } -Parameters $Global:AadSupport.Session.TenantId

    $result = @()
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            $context = Invoke-AzureCommand -Command { 
                Param($Params)
                #$context = Get-AzSubscription -Subscription $Params.SubscriptionId -TenantId $Params.TenantId
                Set-AzContext -Tenant $Params.TenantId -Subscription $Params.SubscriptionId | Out-Null
            } -Parameters @{
                SubscriptionId = $sub.id
                TenantId = $TenantId
            } -SubscriptionId $sub.id
            
            # Get Role Assignments
            if($ServicePrincipalName)
            {
                $RoleAssignments = @()
                $AzRoleAssignments = Invoke-AzureCommand -Command { Get-AzRoleAssignment } -SubscriptionId $sub.id

                # Get Direct Assignments
                $RoleAssignments += Invoke-AzureCommand -Command {
                    Param($ServicePrincipalName)
                    Get-AzRoleAssignment -ServicePrincipalName $ServicePrincipalName
                } -Parameters $ServicePrincipalName -SubscriptionId $sub.id

                # Get groups assigned to Azure RBAC (we need to check each group)
                $GroupIdsCheck = ($AzRoleAssignments | where {$_.ObjectType -eq "Group"}).ObjectId

                $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
                $Groups.GroupIds = $GroupIdsCheck

                # Check if ServicePrincipal is a member of any of those groups
                $IsMemberOf = Invoke-AadCommand -Command {
                    Param($Params)
                    Select-AzureADGroupIdsServicePrincipalIsMemberOf -ObjectId $Params.ObjectId -GroupIdsForMembershipCheck $Params.Groups
                } -Parameters @{
                    ObjectId = $ObjectId
                    Groups = $Groups
                }

                # Get Azure RBAC for the groups in which the Service Principal is a member of
                foreach($GroupId in $IsMemberOf)
                {
                    $RoleAssignments += $AzRoleAssignments | Where-Object { $_.ObjectId -eq $GroupId }
                }
                
                
            }

            if($SigninName)
            {
                $RoleAssignments = Invoke-AzureCommand -Command {
                    Param($SigninName)
                    Get-AzRoleAssignment -SignInName $SigninName -ExpandPrincipalGroups
                } -Parameters $SigninName -SubscriptionId $sub.id
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
                        $AssignedDisplayName = (
                            Invoke-AadCommand -Command {
                                Param($Role)
                                Get-AzureADObjectByObjectId -ObjectIds $Role.ObjectId
                            } -Parameters $Role
                            
                        ).DisplayName

                        $GetsAssignmentBy = "$($AssignedDisplayName) ($($Role.ObjectId))"
                    }

                    $ResourceName = ""
                    if($Role.Scope)
                    {
                        $Split = $Role.Scope.Split("/")
                        $ResourceName = $Split[$Split.Lenth-1]
                    }
                    
                    $CustomResult = [pscustomobject]@{
                        Scope = $Role.Scope
                        RoleName = $Role.RoleDefinitionName
                        ResourceName = $ResourceName
                        DirectAssignment = $DirectAssignment
                        GetsAssignmentBy = $GetsAssignmentBy
                    }
    
                    $result += $CustomResult 
                }
            }
        }
    }

    return $result
}