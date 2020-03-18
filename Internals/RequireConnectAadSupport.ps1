function RequireConnectAadSupport()
{
    if(-not $Global:AadSupport.Session.Active) 
    { 
        Write-Host "Please run 'Connect-AadSupport' first." -ForegroundColor Yellow
        throw "Running 'Connect-AadSupport' required"
    }
}
