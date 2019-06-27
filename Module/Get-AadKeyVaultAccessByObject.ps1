function Get-AadKeyVaultAccessByObject {

    param(
        [Parameter(
            ValueFromPipeline = $true,
            ParameterSetName = "ByObjectId")]
        $ObjectId,

        [Parameter(ParameterSetName = "ByObjectId")]
        [parameter(ValueFromPipeline=$true)]
        [ValidateSet("User","ServicePrincipal")]
        [string]$ObjectType,

        [Parameter(ParameterSetName = "ByServicePrincipalId")]
        $ServicePrincipalId,

        [Parameter(ParameterSetName = "ByUserId")]
        $UserId
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    if($ObjectId -and -not $ObjectType)
    {
        $ObjectType = (Get-AzureADObjectByObjectId -ObjectIds $ObjectId).ObjectType
    }

    # Search for ServicePrincipal
    if($ServicePrincipalId)
    {
        $ObjectType = "ServicePrincipal"
        $sp = Get-AadServicePrincipal -Id $ServicePrincipalId

        If(-not $sp)
        {
            return 
        }

        $ObjectId = $sp.ObjectId
    }
    
    # Search for User
    if($UserId)
    {
        $ObjectType = "User"

        $user = Get-AzureADUser -ObjectId $UserId

        If(-not $user)
        {
            return 
        }

        $ObjectId = $user.ObjectId
    }


    $subscriptions = Get-AzSubscription -TenantId $Global:AadSupport.Session.TenantId

    $result = @()
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            Write-Verbose "Checking Subscription '$($sub.Name) (Id:$($sub.id))'  "
            Select-AzSubscription -SubscriptionId $sub.id | Out-Null
            $KeyVaults = Get-AzKeyVault
            foreach($KeyVaultItem in $KeyVaults)
            {
                $KeyVaultName = $KeyVaultItem.VaultName
                Write-Verbose "Checking Key Vault '$KeyVaultName'"
                $kv = Get-AzKeyVault -VaultName $KeyVaultName
                foreach($policy in $kv.AccessPolicies)
                {
                    $PolicyAssignedObject = (Get-AzureADObjectByObjectId -ObjectIds $policy.ObjectId)
                    if($PolicyAssignedObject.ObjectType -eq "Group")
                    {
                        # Check if User/ServicePrincipal is a member of the group
                        $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
                        $Groups.GroupIds = $policy.ObjectId

                        if($ObjectType -eq "User")
                        {
                            $IsMemberOf = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $ObjectId -GroupIdsForMembershipCheck $Groups
                        }

                        if($ObjectType -eq "ServicePrincipal")
                        {
                            $IsMemberOf = Select-AzureADGroupIdsServicePrincipalIsMemberOf -ObjectId $ObjectId -GroupIdsForMembershipCheck $Groups
                        }
                        
                        # I only want to show group info if the object is assigned through group membership
                        if($IsMemberOf)
                        {
                            $DirectAssignment = $false
                            $GroupDisplayName = $PolicyAssignedObject.DisplayName
                            $GroupObjectId = $PolicyAssignedObject.ObjectId
                        }
                        else {
                            $DirectAssignment = $true
                        }
                    }

                    if($policy.ObjectId -eq $ObjectId -or $IsMemberOf)
                    {
                        $CustomResult = [ordered]@{}
                        $CustomResult.KeyVaultName = $KeyVaultName
                        $CustomResult.PermissionsToSecrets = $policy.PermissionsToSecrets
                        $CustomResult.PermissionsToKeys = $policy.PermissionsToKeys
                        $CustomResult.PermissionsToCertificates = $policy.PermissionsToCertificates
                        $CustomResult.PermissionsToStorage = $policy.PermissionsToStorage
                        $CustomResult.DirectAssignment = $DirectAssignment
                        $CustomResult.GetsAssignmentBy = "$GroupDisplayName ($GroupObjectId)"
                        
                        $result += $CustomResult
                    }
                }
            }
        }
    }

    return $result
}