---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Get-AadDiscoveryKeys

## SYNOPSIS
Gets the Azure AD Discovery Keys

## SYNTAX

### Default (Default)
```
Get-AadDiscoveryKeys [-ApplicationId <String>] [<CommonParameters>]
```

### SetTenantAndInstance
```
Get-AadDiscoveryKeys [-Tenant <String>] [-AadInstance <String>] [-ApplicationId <String>] [<CommonParameters>]
```

### SetIssuer
```
Get-AadDiscoveryKeys [-Issuer <String>] [-ApplicationId <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the Azure AD Discovery Keys

PS C:\\\>Get-AadDiscoveryKeys
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
                6:00:00 PM; Issuer=CN=accounts.accesscontrol.windows.net; Certificate=\[Subject\]
                  CN=accounts.accesscontrol.windows.net

                \[Issuer\]
                  CN=accounts.accesscontrol.windows.net

                \[Serial Number\]
                  19BE4B61B2A8DC874CD0742C8EFFA612

                \[Not Before\]
                  12/25/2019 6:00:00 PM

                \[Not After\]
                  12/24/2024 6:00:00 PM

                \[Thumbprint\]
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

## EXAMPLES

### EXAMPLE 1
```
Get-AadDiscoveryKeys
```

### EXAMPLE 2
```
Get-AadDiscoveryKeys -Tenant contoso.onmicrosoft.com -ApplicationId bcdeb54f-733b-4657-8948-0f39934c2a53
```

### EXAMPLE 3
```
Get-AadDiscoveryKeys -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/"
```

## PARAMETERS

### -Tenant
Specify the tenant.
This would be required if getting specific information about an app

```yaml
Type: String
Parameter Sets: SetTenantAndInstance
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AadInstance
Specify the Azure AD Instance i.e.
https://login.microsoftonline.com or https://login.microsoftonline.us

```yaml
Type: String
Parameter Sets: SetTenantAndInstance
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issuer
You can specify the full Issuer.
This would be required to correctly get discovery keys for Azure AD B2C

```yaml
Type: String
Parameter Sets: SetIssuer
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApplicationId
Specify the Application ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
