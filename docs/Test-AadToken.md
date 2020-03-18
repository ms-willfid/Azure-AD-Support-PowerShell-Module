---
external help file: _RootModuleShared-help.xml
Module Name: AadSupport
online version:
schema: 2.0.0
---

# Test-AadToken

## SYNOPSIS
Quickly validate tokens issued by Azure AD.

## SYNTAX

```
Test-AadToken [-JwtToken] <String> [-Issuer <String>] [<CommonParameters>]
```

## DESCRIPTION
Quickly validate tokens issued by Azure AD.

WARNING: Access token for Microsoft Graph can not be validated.
This is expected and only Microsoft Graph will be able to validate its own token.

When running this command while Connected to AadSupport (Connect-AadSupport) we will also lookup the Resource AppId and add the signing keys to the list of keys to be verified.
We do this because sometimes the resource might use a different signing key that is not the standard Azure AD set of keys. 

The results will look something like this...

Validate-AadToken -JwtToken $token.AccessToken

Kid in token: xGbI8ASfxBGw3u14fNXYJhG-wlU

Getting Keys based on Issuer 'https://sts.windows.net/aa00d1fa-5269-4e1c-b06d-30868371d2c5/'...
Downloading configuration from 'https://sts.windows.net/aa00d1fa-5269-4e1c-b06d-30868371d2c5/.well-known/openid-configuration'
Downloading signing keys from 'https://login.windows.net/common/discovery/keys'

Keys Found...
HlC0R12skxNZ1WQwmjOF_6t_tDE
YMELHT0gvb0mxoSDoYfomjqfjYU
M6pX7RHoraLsprfJeRCjSxuURhc

Getting Keys for the Resource bcdeb54f-733b-4657-8948-0f39934c2a53...
Downloading configuration from 'https://sts.windows.net/aa00d1fa-5269-4e1c-b06d-30868371d2c5/.well-known/openid-configuration?appid=bcdeb54f-733b-4657-8948-0f39934c2a53'
Downloading signing keys from 'https://login.windows.net/aa00d1fa-5269-4e1c-b06d-30868371d2c5/discovery/keys?appid=bcdeb54f-733b-4657-8948-0f39934c2a53'

Keys Found...
xGbI8ASfxBGw3u14fNXYJhG-wlU

Checking Discovery Key: HlC0R12skxNZ1WQwmjOF_6t_tDE | Signature validation failed
Checking Discovery Key: YMELHT0gvb0mxoSDoYfomjqfjYU | Signature validation failed
Checking Discovery Key: M6pX7RHoraLsprfJeRCjSxuURhc | Signature validation failed
Checking Discovery Key: xGbI8ASfxBGw3u14fNXYJhG-wlU | Signature is verified

## EXAMPLES

### EXAMPLE 1
```
Validate-AadToken -JwtToken $AccessToken
```

Validate-AadToken -JwtToken $AccessToken -Issuer "https://login.microsoftonline.com/contoso.onmicrosoft.com"
Validate-AadToken -JwtToken $AccessToken -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/.well-known/openid-configuration"

## PARAMETERS

### -JwtToken
Provide the token to be validated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Issuer
Issuer you want to use.
We will use this to get the Open ID Connect Configuration based on the Issuer.

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
