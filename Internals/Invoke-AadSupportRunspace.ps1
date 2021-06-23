function Invoke-AadSupportRunspace
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
        $Runspace
    )

    Write-Host "Starting Runspace"

    "Invoking ADAL Runspace with Command..." | Log-AadSupport 
    $Command | Log-AadSupport 

    if($Parameters) {
        "Params for Command..." | Log-AadSupport
        $Parameters | Log-AadSupport 
    }

    $ErrorHandlingBegin = {
        $Error.Clear()
    }

    $ErrorHandlingEnd = {
         $Error
    }

    # Setup Runspace
    $RunspaceName = "AadSupportRunspace"
    $PowerShell = [powershell]::Create()

    $PowerShell.runspace = $Runspace.Instance
    $PowerShell.runspace.Name = $RunspaceName

    $RunspaceState = $PowerShell.runspace.RunspaceStateInfo.State
    if($RunspaceState -eq "BeforeOpen")
    {
        $PowerShell.runspace = $PowerShell.runspace.Open()
    }

    # Clear errors in runspace
    [void]$PowerShell.AddScript($ErrorHandlingBegin)

    # IMPORT LOGGING IN RUNSPACE
    $PowerShell.runspace.SessionStateProxy.SetVariable('GlobalParams',$Global:AadSupport)

    [void]$PowerShell.AddScript({
        $ImportLogging = "$($GlobalParams.Path)\Internals\imports\Log-AadSupportRunspace.ps1"
        . $ImportLogging 
    })
    
    $PowerShell.Invoke()
    $PowerShell.Commands.Clear()

    # Lets start running our 'calling' commands in Runspace
    # Run Command
    Write-Host "$($PowerShell.runspace.RunspaceStateInfo.State)" -ForegroundColor Yellow
    [void]$PowerShell.AddScript($Command).AddArgument($Parameters)
    $RunCommand = $PowerShell.BeginInvoke()
    $PowerShell.Commands.Clear()

    # Get Errors inside runspace
    [void]$PowerShell.AddScript($ErrorHandlingEnd)
    $ErrorInsideRunspace = $PowerShell.Invoke()

    $PowerShell.Dispose()


    if($RunCommand)
    {
        $RunCommand | Log-AadSupport
        Write-Host "Runspace Complete"
        return $RunCommand
    }

    if($ErrorInsideRunspace)
    {
        $ErrorInsideRunspace | Log-AadSupport -Force
        Write-Host "Runspace Errors"
        return $ErrorInsideRunspace
    }

    Write-Host "Runspace unknown failure"
}