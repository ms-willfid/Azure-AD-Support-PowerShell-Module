
<#
.SYNOPSIS
Gets the Azure AD Discovery Keys

.DESCRIPTION
Gets the Azure AD Discovery Keys

PS C:\>Get-AadDiscoveryKeys
Downloading configuration from 'https://login.microsoftonline.com/aa00d1fa-5269-4e1c-b06d-30868371d2c5/.well-known/openid-configuration'
Downloading signing keys from 'https://login.microsoftonline.com/common/discovery/keys'

ApplicationId :
Kid           : HlC0R12skxNZ1WQwmjOF_6t_tDE
Use           : sig
x5t           : HlC0R12skxNZ1WQwmjOF_6t_tDE
kty           : RSA
Modulus       : vq_3TOSbrUzpGPHFEwjmeoE_Zu3-wU4vaeEvjQzUHXwIefy8bDuMav6OzUiEXhjLX5JRkGhds3lNGR3CSZgartIKWv5Vrc7F2YcBcgz
                rpO06kVcewRMjdhrPYfUfO6QklAOSCcPq4RUhEvkGEwbAw3awclve1KuhpX6fOIInP8Gp8hrFDd_neBR3AY03JrZpezBdQoE24UHgAl
                HGb2UZ2KKjl3rLDMPh9HecjTiga3SbdcrhTAOYHYb4LwCSrThrHSyZFBxzTwQMS0NEyKV7_-ADrFunf9cuVcGpQZkvdwODl4tY-l2sd
                3WpoD_gMDpoFJVojjzF07ovrfntM4o8Bw
Exponent      : AQAB
Certificate   : @{Subject=CN=accounts.accesscontrol.windows.net; Kid=HlC0R12skxNZ1WQwmjOF_6t_tDE; NotAfter=12/24/2024
                6:00:00 PM; Issuer=CN=accounts.accesscontrol.windows.net; Certificate=[Subject]
                  CN=accounts.accesscontrol.windows.net

                [Issuer]
                  CN=accounts.accesscontrol.windows.net

                [Serial Number]
                  19BE4B61B2A8DC874CD0742C8EFFA612

                [Not Before]
                  12/25/2019 6:00:00 PM

                [Not After]
                  12/24/2024 6:00:00 PM

                [Thumbprint]
                  1E50B4475DAC931359D564309A3385FFAB7FB431
                ; Thumbprint=1E50B4475DAC931359D564309A3385FFAB7FB431; NotBefore=12/25/2019 6:00:00 PM}
Thumbprint    : 1E50B4475DAC931359D564309A3385FFAB7FB431
x5c           : MIIDBTCCAe2gAwIBAgIQGb5LYbKo3IdM0HQsjv+mEjANBgkqhkiG9w0BAQsFADAtMSswKQYDVQQDEyJhY2NvdW50cy5hY2Nlc3Njb25
                0cm9sLndpbmRvd3MubmV0MB4XDTE5MTIyNjAwMDAwMFoXDTI0MTIyNTAwMDAwMFowLTErMCkGA1UEAxMiYWNjb3VudHMuYWNjZXNzY2
                9udHJvbC53aW5kb3dzLm5ldDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL6v90zkm61M6RjxxRMI5nqBP2bt/sFOL2nhL
                40M1B18CHn8vGw7jGr+js1IhF4Yy1+SUZBoXbN5TRkdwkmYGq7SClr+Va3OxdmHAXIM66TtOpFXHsETI3Yaz2H1HzukJJQDkgnD6uEV
                IRL5BhMGwMN2sHJb3tSroaV+nziCJz/BqfIaxQ3f53gUdwGNNya2aXswXUKBNuFB4AJRxm9lGdiio5d6ywzD4fR3nI04oGt0m3XK4Uw
                DmB2G+C8Akq04ax0smRQcc08EDEtDRMile//gA6xbp3/XLlXBqUGZL3cDg5eLWPpdrHd1qaA/4DA6aBSVaI48xdO6L6357TOKPAcCAw
                EAAaMhMB8wHQYDVR0OBBYEFMGZU4IfHXk8nigJzTMM45KzMjeVMA0GCSqGSIb3DQEBCwUAA4IBAQAMJF5kk0gj119v4wbQTr9sQr9SS
                7ALfmIBQaeWjWRZvmXbEnMMA46y9nShV+d3cFrIrxuz7ynd3PU0+2HP4217VHO3rFyNbNnp4IB+BJa+hW/Hi54X+m/QPztDFCdiP1zY
                Wr7DNEvnebuAMAJ+W0I08h5yIcX6Z0TTZcrWc72Qyi2Y2MuYDN+AVvQ1WZWsU4gbnUK7oj8bYnLfzWWuhfks2vC5Sbx9+79j+36HtsQ
                nYe9ouxQ5vfNxm7wcLTQQulU16lnD0yObvr1hfteKfuW2/Ynoy5Z2ntIyCbGxiulaPLrFTW4gUhYgnteB5CwGw1C5vhv0Aa+XZouHVh
                oOLhWF

.PARAMETER Tenant
Specify the tenant. This would be required if getting specific information about an app

.PARAMETER AadInstance
Specify the Azure AD Instance i.e. https://login.microsoftonline.com or https://login.microsoftonline.us

.PARAMETER Issuer
You can specify the full Issuer. This would be required to correctly get discovery keys for Azure AD B2C

.PARAMETER ApplicationId
Specify the Application ID

.EXAMPLE
Get-AadDiscoveryKeys 

.EXAMPLE
Get-AadDiscoveryKeys -Tenant contoso.onmicrosoft.com -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53

.EXAMPLE
Get-AadDiscoveryKeys -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/"

.NOTES
General notes
#>
function Get-AadDiscoveryKeys
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName = 'SetTenantAndInstance')]
        [string]$Tenant, 

        [Parameter(ParameterSetName = 'SetTenantAndInstance')]
        [string]$AadInstance,

        [Parameter(ParameterSetName = 'SetIssuer')]
        [string]$Issuer,

        [string]$ApplicationId
    ) 

    if($Issuer)
    {
        $Configuration = (Get-AadOpenIdConnectConfiguration -Issuer $Issuer -ApplicationId $ApplicationId)
    }
    else
    {
        $Configuration = (Get-AadOpenIdConnectConfiguration -Tenant $Tenant -AadInstance $AadInstance -ApplicationId $ApplicationId)
    }

    $KeyUrl = $Configuration.jwks_uri

    # Get the Discovery Keys
    Write-Host "Downloading signing keys from '$KeyUrl'"
    $Keys = (ConvertFrom-Json (Invoke-WebRequest $KeyUrl).Content).Keys
    
    # Build the Output object
    $ReturnObject = @()

    foreach($Key in $Keys)
    {
        $Object = [pscustomobject]@{} 

        $Object | Add-Member -NotePropertyName ApplicationId -NotePropertyValue $Configuration.ApplicationId
        $Object | Add-Member -NotePropertyName Kid -NotePropertyValue $Key.kid
        $Object | Add-Member -NotePropertyName Use -NotePropertyValue $Key.use
        $Object | Add-Member -NotePropertyName x5t -NotePropertyValue $Key.x5t
        $Object | Add-Member -NotePropertyName kty -NotePropertyValue $Key.kty
        $Object | Add-Member -NotePropertyName Modulus -NotePropertyValue $Key.n
        $Object | Add-Member -NotePropertyName Exponent -NotePropertyValue $Key.e

        if($Key.x5c)
        {
            $Certificate = ConvertFrom-AadBase64Certificate -Base64String $Key.x5c[0]
            $Thumbprint = $Certificate.Thumbprint

            $Object | Add-Member -NotePropertyName Certificate -NotePropertyValue $Certificate
            $Object | Add-Member -NotePropertyName Thumbprint -NotePropertyValue $Thumbprint
            $Object | Add-Member -NotePropertyName x5c -NotePropertyValue $Key.x5c[0]
        }

        $ReturnObject += $Object
    }

    return $ReturnObject
}


function Test-Get-AadDiscoveryKeys
{
    # Provide no info
    Get-AadDiscoveryKeys 

    # Provide a tenant
    Get-AadDiscoveryKeys -Tenant "williamfiddesb2c.onmicrosoft.com"

    # Provide a instance
    Get-AadDiscoveryKeys -AadInstance "https://login.microsoftonline.us"

    # Provide a Issuer with a appid
    Get-AadDiscoveryKeys -Issuer https://login.microsoftonline.com/williamfiddes.onmicrosoft.com/.well-known/openid-configuration?appid=bcdeb54f-733b-4657-8948-0f39934c2a53

    # Provide a appid
    Get-AadDiscoveryKeys -Tenant "williamfiddes.onmicrosoft.com" -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53

    # Provide a B2C Issuer
    Get-AadDiscoveryKeys -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/.well-known/openid-configuration"
    
}
