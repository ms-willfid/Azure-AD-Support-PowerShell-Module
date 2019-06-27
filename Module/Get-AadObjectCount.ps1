function Get-AadObjectCount
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param
    (
        [switch]$Users,
        [switch]$Groups,
        [switch]$Devices,
        [switch]$Contacts
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    if(-not $Users -and -not $Groups -and -not $Devices -and -not $Contacts)
    {
        $Users = $true
        $Groups = $true
        $Devices = $true
        $Contacts = $true
    }

    $MsGraphEndpoint = $Global:AadSupport.Resources.MsGraph

    Write-Host "Getting User Count."
    $UserCount = (Get-AzureADUser -All $true).Count
    $UserDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.User").Count

    Write-Host "Getting Group Count."
    $GroupCount = (Get-AzureADGroup -All $true).Count
    $GroupDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.Group").Count

    Write-Host "Getting Device Count."
    $DeviceCount = (Get-AzureADDevice -All $true).Count
    $DeviceDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/v1.0/directory/deletedItems/Microsoft.Graph.Device").Count

    Write-Host "Getting Contact (Organizational) Count."
    $ContactCount = (Get-AzureADContact -All $true).Count
    $ContactDeletedCount = (Invoke-AadProtectedApi -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId -Resource $MsGraphEndpoint -Endpoint "$MsGraphEndpoint/beta/directory/deletedItems/Microsoft.Graph.orgContact").Count
    
    $TotalActiveCount = $UserCount +$GroupCount +$DeviceCount +$ContactCount 
    $TotalDeletedCount = $UserDeletedCount +$GroupDeletedCount +$DeviceDeletedCount +$ContactDeletedCount

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
    Write-Host ""
    Write-Host "Total Count: $TotalCount"
    Write-Host ""
    Write-Host "Note: Deleted objects only count for 1/4 against Object Quota."
    Write-Host "Total Count against Directory Quota: $TotalValidCount"
    Write-Host ""
}