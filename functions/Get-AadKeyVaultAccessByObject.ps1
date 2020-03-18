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

    if($ObjectId -and -not $ObjectType)
    {
        $ObjectType = Invoke-AadCommand -Command {
            Param($ObjectId)
             (Get-AzureADObjectByObjectId -ObjectIds $ObjectId).ObjectType
        } -Parameters $ObjectId
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

        $user = $ObjectType = Invoke-AadCommand -Command {
            Param($UserId)
            Get-AzureADUser -ObjectId $UserId
        } -Parameters $UserId

        If(-not $user)
        {
            return 
        }

        $ObjectId = $user.ObjectId
    }


    $subscriptions = Invoke-AzureCommand -Command {
        Param($TenantId)
        Get-AzSubscription -TenantId $TenantId
      } -Parameters $Global:AadSupport.Session.TenantId

    $result = @()
    foreach($sub in $subscriptions) {
        
        if($sub.Name -ne "Access to Azure Active Directory")
        {
            Write-Verbose "Checking Subscription '$($sub.Name) (Id:$($sub.id))'  "
            <#
            Invoke-AzureCommand -Command { 
                Param($SubscriptionId)
                Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
            } -Parameters $sub.id -SubscriptionId $sub.id
            #>
            
            $KeyVaults = Invoke-AzureCommand -Command { Get-AzKeyVault } -SubscriptionId $sub.id
            foreach($KeyVaultItem in $KeyVaults)
            {
                $KeyVaultName = $KeyVaultItem.VaultName
                Write-Verbose "Checking Key Vault '$KeyVaultName'"
                $kv = Invoke-AzureCommand -Command {
                    Param($KeyVaultName)
                     Get-AzKeyVault -VaultName $KeyVaultName
                } -Parameters $KeyVaultName -SubscriptionId $sub.id

                foreach($policy in $kv.AccessPolicies)
                {
                    $PolicyAssignedObject = Invoke-AadCommand -Command {
                        Param($ObjectIds)
                        (Get-AzureADObjectByObjectId -ObjectIds $ObjectIds)
                    } -Parameters $policy.ObjectId

                    if($PolicyAssignedObject.ObjectType -eq "Group")
                    {
                        # Check if User/ServicePrincipal is a member of the group
                        $Groups = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
                        $Groups.GroupIds = $policy.ObjectId

                        if($ObjectType -eq "User")
                        {
                            $IsMemberOf = Invoke-AadCommand -Command {
                                Param($Params)
                                Select-AzureADGroupIdsUserIsMemberOf -ObjectId $Params.ObjectId -GroupIdsForMembershipCheck $Params.Groups
                            } -Parameters @{
                                ObjectId = $ObjectId
                                Groups = $Groups
                            }
                        }

                        if($ObjectType -eq "ServicePrincipal")
                        {
                            $IsMemberOf = Invoke-AadCommand -Command {
                                Param($Params)
                                Select-AzureADGroupIdsServicePrincipalIsMemberOf -ObjectId $Params.ObjectId -GroupIdsForMembershipCheck $Params.Groups
                            } -Parameters @{
                                ObjectId = $ObjectId
                                Groups = $Groups
                            }
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