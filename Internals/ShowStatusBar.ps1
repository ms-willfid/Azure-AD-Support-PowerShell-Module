function Show-AadSupportStatusBar
{
    if(!$Global:AadSupport.StatusBar)
    {
        $Global:AadSupport.StatusBar = 0
    }

    if($Global:AadSupport.StatusBar % 10 -eq 0)
    {
        Write-Host "." -ForegroundColor Yellow -NoNewline
        $Global:AadSupport.StatusBar = 0
    }
    $Global:AadSupport.StatusBar++
}