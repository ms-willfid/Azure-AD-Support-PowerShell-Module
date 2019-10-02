function Invoke-AadCommand
{
    
    param
    (
        [string]$Command
    )


    $PowerShell = [powershell]::Create()
    $PowerShell.runspace = $Global:AadSupport.Runspace.AzureAd.Instance
    $RunspaceState = $Global:AadSupport.Runspace.AzureAd.Instance.RunspaceStateInfo.State
    if($RunspaceState -eq "BeforeOpen")
    {
        $PowerShell.runspace = $Global:AadSupport.Runspace.AzureAd.Instance.Open()
    }
    
    
    [void]$PowerShell.AddScript($Command)
    $PowerShell.Invoke()
    
    $PowerShell.Dispose()
}