function Invoke-MSOnlineCommand
{
    
    param
    (
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        $Command,
        $Parameters

    )

    "Invkoking MsOnline PSH" | Log-AadSupport 
    $Command | Log-AadSupport 

    if($Parameters) {
        "Params for Command..." | Log-AadSupport
        $Parameters | Log-AadSupport 
    }

    $ConnectState = $Global:AadSupport.Runspace.MSOnline.Connected
    if(-not $ConnectState -and $Command -ne "Connect-MsolService")
    {
        try {
            Invoke-MSOnlineCommand -Command "Connect-MsolService"
        }
        catch {
            throw $_
        }
        
        $Global:AadSupport.Runspace.MSOnline.Connected = $true
    }

    $PowerShell = [powershell]::Create()
    $PowerShell.runspace = $Global:AadSupport.Runspace.MSOnline.Instance
    $RunspaceState = $Global:AadSupport.Runspace.MSOnline.Instance.RunspaceStateInfo.State
    if($RunspaceState -eq "BeforeOpen")
    {
        $PowerShell.runspace = $Global:AadSupport.Runspace.MSOnline.Instance.Open()
    }
    
    # IMPORT LOGGING IN RUNSPACE
    $PowerShell.runspace.SessionStateProxy.SetVariable('GlobalParams',$Global:AadSupport)

    [void]$PowerShell.AddScript({
        $ImportLogging = "$($GlobalParams.Path)\Internals\imports\Log-AadSupportRunspace.ps1"
        . $ImportLogging 
    })
    
    $PowerShell.Invoke()
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
    
    $PowerShell.Dispose()
}