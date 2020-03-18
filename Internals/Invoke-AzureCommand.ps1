
<# EXAMPLE USAGE
$MyParams = @{
    UserId = $AccountId
}

Invoke-AadCommand -Command {
    Param($params)
    Get-AzureADUser -ObjectId $params.UserId
} -Parameters $MyParams
#>

function Invoke-AzureCommand
{
    
    [CmdletBinding()]
    Param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        $Command,
        $Parameters,
        $SubscriptionId
    )

    "Invoking Azure PSH... Runspace ID:" + $($Global:AadSupport.Runspace.AzureAd.Instance.Id) | Log-AadSupport 
    $Command | Log-AadSupport 

    if($Parameters) {
        "Params for Command..." | Log-AadSupport
        $Parameters | Log-AadSupport 
    }

    if($SubscriptionId) {
        "Azure Subscription ID..." | Log-AadSupport
        $SubscriptionId | Log-AadSupport 
    }
    
    $Error.Clear()

    # Get Token for AAD Graph to be used for Azure PowerShell
    $AadToken = Get-AadTokenUsingAdal `
      -ResourceId $Global:AadSupport.Resources.AadGraph `
      -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
      -Redirect $Global:AadSupport.Clients.AzureAdPowershell.RedirectUri `
      -Tenant $Global:AadSupport.Session.TenantDomain `
      -UserId $Global:AadSupport.Session.AccountId `
      -Prompt "Auto" `
      -SkipServicePrincipalSearch `
      -HideOutput

    # Get Token for Azure Graph to be used for Azure PowerShell
    $AzureToken = Get-AadTokenUsingAdal `
      -ResourceId $Global:AadSupport.Resources.AzureServiceApi `
      -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
      -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
      -Tenant $Global:AadSupport.Session.TenantDomain `
      -UserId $Global:AadSupport.Session.AccountId `
      -Prompt "Auto" `
      -SkipServicePrincipalSearch `
      -HideOutput

    $AzureGraphToken = Get-AadTokenUsingAdal `
    -ResourceId $Global:AadSupport.Resources.AzureRmApi `
    -ClientId $Global:AadSupport.Clients.AzurePowershell.ClientId `
    -Redirect $Global:AadSupport.Clients.AzurePowershell.RedirectUri `
    -Tenant $Global:AadSupport.Session.TenantDomain `
    -UserId $Global:AadSupport.Session.AccountId `
    -Prompt "Auto" `
    -SkipServicePrincipalSearch `
    -HideOutput

    if($token.Error)
    {
        return "Run Connect-AadSupport"
    }


    $AadAccessToken = $AadToken.AccessToken
    $AzureAccessToken = $AzureToken.AccessToken
    $AzureGraphAccessToken = $AzureGraphToken.AccessToken

    $ErrorHandlingBegin = {
        $Error.Clear()
    }

    $ErrorHandlingEnd = {
        $Error
    }

    $ConnectParams = @{
        TenantId = $Global:AadSupport.Session.TenantId
        AzureEnvironmentName = $Global:AadSupport.Session.AzureEnvironmentName
        AadAccessToken = $AadAccessToken
        GraphAccessToken = $AzureGraphAccessToken
        AzureAccessToken = $AzureAccessToken
        AccountId = $Global:AadSupport.Session.AccountId
        SubscriptionId = $SubscriptionId
    }



    $ConnectCommand = {
        Param($Params)
        Clear-AzContext -Force
        $AzureSession = Connect-AzAccount `
        -AccessToken $Params.AzureAccessToken `
        -GraphAccessToken $Params.AadAccessToken `
        -AccountId $Params.AccountId `
        -Tenant $Params.TenantId 
        return $AzureSession
    }

    $ConnectCommandWithSubscription = {
        Param($Params)
        Clear-AzContext -Force
        $AzureSession = Connect-AzAccount `
        -AccessToken $Params.AzureAccessToken `
        -GraphAccessToken $Params.AadAccessToken `
        -AccountId $Params.AccountId `
        -Tenant $Params.TenantId `
        -Subscription $Params.SubscriptionId
        return $AzureSession
    }

    # Set up runspace
    $PowerShell = [powershell]::Create()
    $PowerShell.runspace = $Global:AadSupport.Runspace.AzureAd.Instance
    $RunspaceState = $Global:AadSupport.Runspace.AzureAd.Instance.RunspaceStateInfo.State
    if($RunspaceState -eq "BeforeOpen")
    {
        $PowerShell.runspace = $Global:AadSupport.Runspace.AzureAd.Instance.Open()
    }
    
    # IMPORT LOGGING IN RUNSPACE
    [void]$PowerShell.AddScript($ErrorHandlingBegin)
    $PowerShell.runspace.SessionStateProxy.SetVariable('GlobalParams',$Global:AadSupport)

    [void]$PowerShell.AddScript({
        $ImportLogging = "$($GlobalParams.Path)\Internals\imports\Log-AadSupportRunspace.ps1"
        . $ImportLogging 
    })
    
    $PowerShell.Invoke()
    $PowerShell.Commands.Clear()
    
    # Connect to Azure (Connect-AzAccountd)

    #$SessionAzureGraphAccessToken = $Global:AadSupport.Session.AzureGraphAccessToken
    #$SessionAzureAccessToken = $Global:AadSupport.Session.AzureAccessToken
    #$SessionAadAccessToken = $Global:AadSupport.Session.AadAccessToken

    #if($SessionAzureGraphAccessToken -ne $AzureGraphAccessToken -and $SessionAzureGraphAccessToken -ne $AzureAccessToken -and $SessionAadAccessToken -ne $AadAccessToken) 
    #{
    if($SubscriptionId)
    {
        [void]$PowerShell.AddScript($ConnectCommandWithSubscription).AddArgument($ConnectParams)
    }
    else {
        [void]$PowerShell.AddScript($ConnectCommand).AddArgument($ConnectParams)
    }
        
    
    $RunConnectAzureAd = $PowerShell.Invoke()
    $PowerShell.Commands.Clear()
    
    #}

    # Update our cached access tokens
    #$Global:AadSupport.Session.AzureGraphAccessToken = $SessionAzureGraphAccessToken
    #$Global:AadSupport.Session.AzureAccessToken = $SessionAzureAccessToken
    #$Global:AadSupport.Session.AadAccessToken = $SessionAadAccessToken
    
    
    # Run command
    [void]$PowerShell.AddScript($Command).AddArgument($Parameters)
    $RunCommand = $PowerShell.Invoke()
    $PowerShell.Commands.Clear()

    # Get errors in runspace
    [void]$PowerShell.AddScript($ErrorHandlingEnd)
    $ErrorInsideRunspace = $PowerShell.Invoke()
    $PowerShell.Commands.Clear()

    if($RunCommand)
    {
        $RunCommand | Log-AadSupport
        return $RunCommand
    }

    if($ErrorInsideRunspace)
    {
        $ErrorInsideRunspace | Log-AadSupport -Force
        throw $ErrorInsideRunspace
    }
}