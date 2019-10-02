function Invoke-MSOnlineCommand
{
    
    param
    (
        [string]$Command
    )

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
    
    
    [void]$PowerShell.AddScript($Command)
    $PowerShell.Invoke()
    
    $PowerShell.Dispose()
}