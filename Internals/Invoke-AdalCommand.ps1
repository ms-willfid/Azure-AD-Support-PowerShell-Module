function Invoke-AdalCommand
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
    $RunspaceName = "AadSupportAdal"
    $PowerShell = [powershell]::Create()

    IF(-not $Global:AadSupportAdalRunspace)
    {
        $Global:AadSupportAdalRunspace = [runspacefactory]::CreateRunspace()
    }

    $PowerShell.runspace = $Global:AadSupportAdalRunspace
    #$PowerShell.runspace = $Global:AadSupport.Runspace.Adal.Instance
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

    # Run Command
    [void]$PowerShell.AddScript($Command).AddArgument($Parameters)
    $RunCommand = $PowerShell.Invoke()
    $PowerShell.Commands.Clear()

    # Get Errors inside runspace
    [void]$PowerShell.AddScript($ErrorHandlingEnd)
    $ErrorInsideRunspace = $PowerShell.Invoke()

    $PowerShell.Dispose()


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

<# TEST #>
<#
$Params = @{}
$MyCommand = {
    Param($params)
    try {
        return "TEST"
        $result = $Global:AdalContext.AcquireToken($params.ResourceId,$params.ClientId,$params.Redirect,$params.Prompt,$params.UserId, $params.ExtraQueryParams)
    
    }
    catch 
    {
        $_
    }
    return $result.AccessToken
}

$myvar = $null
Invoke-AdalCommand -Command $MyCommand -Parameters $Params -OutVariable $myvar

$var
#>