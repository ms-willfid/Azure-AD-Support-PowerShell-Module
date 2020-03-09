function Get-AadDiscoveryKeys
{
    param(
        [string]$Tenant, 
        [string]$AadInstance,
        [string]$ServicePrincipalId,
        [string]$ApplicationId
    ) 

    if($Global:AadSupport.Session)
    {
        $Tenant = $Global:AadSupport.Session.TenantId
        $AadInstance = $Global:AadSupport.Session.AadInstance
    }

    if(-not $Tenant)
    {
        $Tenant = "common"
    }

    if(-not $AadInstance)
    {
        $AadInstance = "https://login.microsoftonline.com"
    }

    if($ServicePrincipalId)
    {
        $sp = Get-AadServicePrincipal -Id $ServicePrincipalId
        $ApplicationId = $sp.AppId
    }

    $KeyUrl = "$AadInstance/$Tenant/discovery/keys"

    if($ApplicationId)
    {
        $KeyUrl += "?appid=$ApplicationId"
    }

    
    $Keys = (ConvertFrom-Json (Invoke-WebRequest $KeyUrl -Verbose).Content).Keys
    
    $ReturnObject = @()

    foreach($Key in $Keys)
    {
        $Certificate = ConvertFrom-AadBase64Certificate -Base64String $Key.x5c[0]
        $Thumbprint = $Certificate.Thumbprint
    
        $Object = [pscustomobject]@{
            kty = $Key.kta
            use = $Key.use
            kid = $Key.kid
            x5t = $Key.x5t
            n = $Key.n
            e = $Key.e
            x5c = $Key.x5c[0]
            Certificate = $Certificate
        } 

        $ReturnObject += $Object
    }

    return $ReturnObject
}

