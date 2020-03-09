function Get-AadUserRealm
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName,

        [string]$AadInstance
    )

    if(-not $AadInstance)
    {
        $AadInstance = $Global:AadSupport.Session.AadInstance
    }
    else
    {
        $AadInstance = $Global:AadSupport.Common.AadInstance
    }

    return (Invoke-WebRequest -Uri "$AadInstance/getuserrealm.srf?login=$UserPrincipalName" -UseBasicParsing).Content | ConvertFrom-Json
}