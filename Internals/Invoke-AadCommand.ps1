
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
        [ScriptBlock]$Command,
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

    Write-Verbose "Connect Parameters..."
    Write-Verbose $ConnectParams | ConvertTo-Json -Depth 99
    
    # IMPORT LOGGING IN RUNSPACE
    $GlobalParams = $Global:AadSupport

    $Global:AadCommandResult = $null

    $ScriptBlock = {
      Param(
          $ConnectParams,
          $AadCommand,
          $AadCommandParams,
          $AadSupport
      )

      Write-Verbose "Running Connect-AzureAd"

      # Connect to AAD PowerShell Module
      $session = Connect-AzureAd `
        -TenantId $ConnectParams.TenantId `
        -AzureEnvironmentName $ConnectParams.AzureEnvironmentName `
        -LogLevel $ConnectParams.LogLevel `
        -LogFilePath $ConnectParams.LogPath `
        -AadAccessToken $ConnectParams.AadAccessToken `
        -MsAccessToken $ConnectParams.MsAccessToken `
        -AccountId $ConnectParams.AccountId

      # Run the AAD PowerShell Command
      $Command = [scriptblock]::Create($AadCommand)

      $Results = Invoke-Command -ScriptBlock $Command -ArgumentList $AadCommandParams 
      $Return = $results | ConvertTo-Json -Depth 99
      return $Return
      
    }

    $Job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $ConnectParams, $Command, $Parameters, $Global:AadSupport

    $Results = $Job | Wait-Job | Receive-Job | ConvertFrom-Json
    return $Results

}