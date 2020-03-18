
<# EXAMPLE USAGE
$MyParams = @{
    UserId = $AccountId
}

Invoke-AadCommand -Command {
    Param($params)
    Get-AzureADUser -ObjectId $params.UserId
} -Parameters $MyParams
#>

function Invoke-AadCommand
{
    
    [CmdletBinding()]
    Param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        $Command,
        $Parameters
    )

    "Invoking Azure AD Runspace..." | Log-AadSupport 
    $Command | Log-AadSupport 

    if($Parameters) {
        "Params for Command..." | Log-AadSupport
        $Parameters | Log-AadSupport 
    }
    

    $Error.Clear()

    if(-not $Global:AadSupport.Session.AccountId)
    {
        Write-Host "Need to run Connect-AadSupport" -ForegroundColor Yellow
        throw "Not Authenticated Yet."
    }

    # Get Token for AAD Graph to be used for Azure AD PowerShell
    $token = Get-AadTokenUsingAdal `
      -ResourceId $Global:AadSupport.Resources.AadGraph `
      -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
      -Redirect $Global:AadSupport.Clients.AzureAdPowershell.RedirectUri `
      -Tenant $Global:AadSupport.Session.TenantId `
      -UserId $Global:AadSupport.Session.AccountId `
      -Prompt "Never" `
      -SkipServicePrincipalSearch `
      -HideOutput

    $AadAccessToken = $token.AccessToken


    $token = $null
    # Get Token for MS Graph to be used for Azure AD PowerShell
    $token = Get-AadTokenUsingAdal `
    -ResourceId $Global:AadSupport.Resources.MsGraph `
    -ClientId $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
    -Redirect $Global:AadSupport.Clients.AzureAdPowershell.RedirectUri `
    -Tenant $Global:AadSupport.Session.TenantId `
    -UserId $Global:AadSupport.Session.AccountId `
    -Prompt "Never" `
    -SkipServicePrincipalSearch `
    -HideOutput
  
    $MsGraphAccessToken = $token.AccessToken

    $ErrorHandlingBegin = {
        $Error.Clear()
    }

    $ErrorHandlingEnd = {
        return $Error
    }

    $ConnectParams = @{
        TenantId = $Global:AadSupport.Session.TenantId
        AzureEnvironmentName = $Global:AadSupport.Session.AzureEnvironmentName
        LogLevel = "Info"
        LogFilePath = "c:\AadSupportLogs\"
        AadAccessToken = $AadAccessToken
        MsAccessToken = $MsGraphAccessToken
        AccountId =$Global:AadSupport.Session.AccountId

    }

    $ConnectCommand = {
        Param($Params)
        $session = Connect-AzureAd `
        -TenantId $Params.TenantId `
        -AzureEnvironmentName $Params.AzureEnvironmentName `
        -LogLevel $Params.LogLevel `
        -LogFilePath $Params.LogPath `
        -AadAccessToken $Params.AadAccessToken `
        -MsAccessToken $Params.MsAccessToken `
        -AccountId $Params.AccountId
        return $session
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
    $PowerShell.runspace.SessionStateProxy.SetVariable('GlobalParams',$Global:AadSupport)

    [void]$PowerShell.AddScript({
        $ImportLogging = "$($GlobalParams.Path)\Internals\imports\Log-AadSupportRunspace.ps1"
        . $ImportLogging 
    })
    
    $PowerShell.Invoke()
    $PowerShell.Commands.Clear()
    
    # Connect to Azure AD (Connect-AzureAd)
    [void]$PowerShell.AddScript($ErrorHandlingBegin)
    [void]$PowerShell.AddScript($ConnectCommand).AddArgument($ConnectParams)
    $RunConnectAzureAd = $PowerShell.Invoke()
    $PowerShell.Commands.Clear()
    
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
        return $ErrorInsideRunspace
    }
}