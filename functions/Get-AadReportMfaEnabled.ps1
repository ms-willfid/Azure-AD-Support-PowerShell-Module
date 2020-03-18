function Get-AadReportMfaEnabled
{
    [CmdletBinding()]
    param()

    $ScriptBlock = { 
        Get-MsolUser -All | where {$_.StrongAuthenticationRequirements.Count -eq 1} | Select-Object -Property UserPrincipalName
    }

    Invoke-MSOnlineCommand -Command  $ScriptBlock
   
}


