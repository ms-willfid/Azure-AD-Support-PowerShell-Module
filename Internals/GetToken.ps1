function GetTokenForMsGraph
{
    # Get Access Token
    $result = Get-AadTokenUsingAdal `
    -ResourceId $Global:AadSupport.Resources.MsGraph `
    -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
    -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
    -UserId $Global:AadSupport.Session.AccountId `
    -SkipServicePrincipalSearch

    # Throw error if can't get Access Token
    if($result.Error) { throw $result.Error }

    # Return Access Token
    return $result.AccessToken
}


function GetTokenForAadGraph
{
    # Get Access Token
    $result = Get-AadTokenUsingAdal `
    -ResourceId $Global:AadSupport.Resources.AadGraph `
    -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
    -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
    -UserId $Global:AadSupport.Session.AccountId `
    -SkipServicePrincipalSearch

    # Throw error if can't get Access Token
    if($result.Error) { throw $result.Error }

    # Return Access Token
    return $result.AccessToken
}