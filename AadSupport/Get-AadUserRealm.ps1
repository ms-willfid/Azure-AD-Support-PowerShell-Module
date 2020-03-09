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
    
    # If AadInstance is still null, lets set a default
    if(-not $AadInstance)
    {
        $AadInstance = "https://login.microsoftonline.com"
    }

    return (Invoke-WebRequest -Uri "$AadInstance/getuserrealm.srf?login=$UserPrincipalName" -UseBasicParsing).Content | ConvertFrom-Json
}