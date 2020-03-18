function Get-AadReportMfaNotEnrolled
{
    [CmdletBinding()]
    param()

    $ScriptBlock = { 
        Get-MsolUser -All | where {$_.StrongAuthenticationMethods.Count -eq 0} | Select-Object -Property UserPrincipalName
    }

    Invoke-MSOnlineCommand -Command  $ScriptBlock
   
}


