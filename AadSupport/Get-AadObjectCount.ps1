function Get-AadObjectCount
{
    $MsGraphEndpoint = $Global:AadSupport.Resources.MsGraph

    Write-Host "Getting User Count."
    $UserCount = Invoke-AadCommand -Command {
        (Get-AzureADUser -All $true).Count
    }

    $UserDeletedCount = 0
    $UserDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.User").Count

    Write-Host "Getting Group Count."
    $GroupCount = Invoke-AadCommand -Command {
        (Get-AzureADGroup -All $true).Count
    }

    $GroupDeletedCount = 0
    $GroupDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.Group").Count

    Write-Host "Getting Device Count."
    $DeviceCount = Invoke-AadCommand -Command {
        (Get-AzureADDevice -All $true).Count
    }

    $DeviceDeletedCount = 0
    $DeviceDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.Device").Count

    Write-Host "Getting Contact (Organizational) Count."
    $ContactCount = Invoke-AadCommand -Command {
        (Get-AzureADContact -All $true).Count
    }

    $ContactDeletedCount = 0
    $ContactDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/beta/directory/deletedItems/Microsoft.Graph.orgContact").Count
    
    Write-Host "Getting Application Count."
    $AppCount = Invoke-AadCommand -Command {
        (Get-AzureADApplication -All $true).Count
    }

    $AppDeletedCount = 0
    $AppDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/beta/directory/deletedItems/Microsoft.Graph.Application").Count
    
    Write-Host "Getting ServicePrincipal Count. This one might take a while."
    $SpCount = Invoke-AadCommand -Command {
        (Get-AzureADServicePrincipal -All $true).Count
    }

    $SpDeletedCount = 0
    $SpDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/beta/directory/deletedItems/Microsoft.Graph.ServicePrincipal").Count
    
    
    Write-Host "Getting OAuth2PermissionGrant Count. This one might take a while."
    $OAuth2PermissionGrantCount = Invoke-AadCommand -Command {
        (Get-AzureADOAuth2PermissionGrant -All $true).Count
    }

    Write-Host "Getting Directory Role Count. This one might take a while."
    $DirectoryRoleCount = Invoke-AadCommand -Command {
        (Get-AzureADDirectoryRole).Count
    }

    $PolicyCount = 0
    if($Global:AadSupport.Powershell.Modules.AzureAd.Name -eq "AzureAdPreview")
    {
        Write-Host "Getting Azure AD Policy Count. This one might take a while."
        $PolicyCount = Invoke-AadCommand -Command {
            (Get-AzureADPolicy -All $true).Count
        }

        if($PolicyCount.Exception)
        {
            $PolicyCount = 0
        }
    }
    

    $TotalActiveCount = $UserCount +$GroupCount +$DeviceCount +$ContactCount +$AppCount +$SpCount +$OAuth2PermissionGrantCount +$DirectoryRoleCount +$PolicyCount
    $TotalDeletedCount = $UserDeletedCount +$GroupDeletedCount +$DeviceDeletedCount +$ContactDeletedCount + $AppDeletedCount +$SpDeletedCount

    $TotalCount = $TotalActiveCount + $TotalDeletedCount

    $TotalValidCount = $TotalActiveCount + [System.Math]::Ceiling($TotalDeletedCount/4)

    Write-Host ""
    Write-Host "Summary..."
    Write-Host " - Users: $UserCount"
    Write-Host "   - Deleted Users: $UserDeletedCount"
    Write-Host " - Groups: $GroupCount"
    Write-Host "   - Deleted Groups: $GroupDeletedCount"
    Write-Host " - Devices: $DeviceCount"
    Write-Host "   - Deleted Devices: $DeviceDeletedCount"
    Write-Host " - Contacts: $ContactCount"
    Write-Host "   - Deleted Contacts: $ContactDeletedCount"
    Write-Host " - Applications: $AppCount"
    Write-Host "   - Deleted Applications: $AppDeletedCount"
    Write-Host " - ServicePrincipals: $SpCount"
    Write-Host "   - Deleted ServicePrincipals: $SpDeletedCount"
    Write-Host " - OAuth2 Permission Grants: $OAuth2PermissionGrantCount"
    Write-Host " - Directory Roles: $DirectoryRoleCount"
    Write-Host " - Azure AD Policies: $PolicyCount (AzureAdPreview Required)"
    Write-Host ""
    Write-Host "Total Count: $TotalCount"
    Write-Host ""
    Write-Host "Note: Deleted objects only count for 1/4 against Object Quota."
    Write-Host "Total Count against Directory Quota: $TotalValidCount"
    Write-Host ""
}