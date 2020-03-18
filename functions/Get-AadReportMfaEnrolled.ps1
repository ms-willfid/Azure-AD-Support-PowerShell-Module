function Get-AadReportMfaEnrolled
{
    [CmdletBinding()]
    param()

    $ScriptBlock = { 
        Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName 
    }

    Invoke-MSOnlineCommand -Command  $ScriptBlock
   
}


