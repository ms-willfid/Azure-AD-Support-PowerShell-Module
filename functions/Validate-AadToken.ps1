
<#
.SYNOPSIS
Quickly validate tokens issued by Azure AD.

.DESCRIPTION
Quickly validate tokens issued by Azure AD.

WARNING: Access token for Microsoft Graph can not be validated. This is expected and only Microsoft Graph will be able to validate its own token.

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

.PARAMETER JwtToken
Provide the token to be validated.

.PARAMETER Issuer
Issuer you want to use. We will use this to get the Open ID Connect Configuration based on the Issuer.

.EXAMPLE
Validate-AadToken -JwtToken $AccessToken
Validate-AadToken -JwtToken $AccessToken -Issuer "https://login.microsoftonline.com/contoso.onmicrosoft.com"
Validate-AadToken -JwtToken $AccessToken -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/.well-known/openid-configuration"

.NOTES
General notes
#>
function Test-AadToken
{
    Param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$JwtToken,
        [string]$Issuer
    )

    Write-Host ""    


    # Get claims for OAuth2Token
    $TokenClaims = ConvertFrom-AadJwtToken $JwtToken

    if($TokenClaims.aud -eq $Global:AadSupport.Resources.MsGraph -or $TokenClaims.aud -eq "00000003-0000-0000-c000-000000000000")
    {
        Write-Host "WARNING! Microsoft Graph tokens can't be validated" -ForegroundColor Red
    }

    Write-Host "Kid in token: $($TokenClaims.Kid)" -Foreground Yellow

    # Ensure Issuer is set (We will use this for the Discovery key endpoint)
    if(!$Issuer)
    {
        $Issuer = $TokenClaims.Iss
    }

    Write-Host ""
    Write-Host "Getting Keys based on Issuer '$Issuer'..." -ForegroundColor Yellow
    $SigningKeys = @()
    $IssuerSigningKeys = Get-AadDiscoveryKeys -Issuer $Issuer

    Write-Host ""
    Write-Host "Keys Found..." -ForegroundColor Yellow
    $IssuerSigningKeys.Kid

    if($Global:AadSupport.Session.Active)
    {
        Write-Host ""
        Write-Host "Getting Keys for the Resource $($TokenClaims.aud)..." -ForegroundColor Yellow
        $resource = Get-AadServicePrincipal -id $TokenClaims.aud
        $AppSigningKeys = Get-AadDiscoveryKeys -Issuer $Issuer -ApplicationId $resource.AppId

        Write-Host ""
        Write-Host "Keys Found..." -ForegroundColor Yellow
        $AppSigningKeys.Kid
    }

    $SigningKeys += $IssuerSigningKeys
    $SigningKeys += $AppSigningKeys

    Write-Host ""
    $ListOfKeysChecked = @()
    foreach($SigningKey in $SigningKeys)
    {
        if(!$ListOfKeysChecked.Contains($SigningKey.Kid) -and $SigningKey.Kid)
        {
            $ListOfKeysChecked += $SigningKey.Kid
            $tokenParts = $JwtToken.Split('.')

            $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
            $rsaParameters = [System.Security.Cryptography.RSAParameters]::new()
            $modulus = Base64UrlDecode -value $SigningKey.Modulus
            $exponent = Base64UrlDecode -value $SigningKey.Exponent
            $rsaParameters.Modulus = [System.Convert]::FromBase64String($modulus)
            $rsaParameters.Exponent = [System.Convert]::FromBase64String($exponent)
        
            $rsa.ImportParameters($rsaParameters)
          
            $sha256 = [System.Security.Cryptography.SHA256]::Create()
            $hash = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($tokenParts[0] + '.' + $tokenParts[1]))
          
            $rsaDeformatter = [System.Security.Cryptography.RSAPKCS1SignatureDeformatter]::new($rsa)
            $rsaDeformatter.SetHashAlgorithm("SHA256")
    
            $TokenSignature = Base64UrlDecode -value $tokenParts[2]
            $TokenSignatureBytes = [System.Convert]::FromBase64String($TokenSignature)
            if ($rsaDeformatter.VerifySignature($hash, $TokenSignatureBytes))
            {
                Write-Host "Checking Discovery Key: $($SigningKey.Kid) | Signature is verified" -Foreground Green
            }
        
            else
            {
                Write-Host "Checking Discovery Key: $($SigningKey.Kid) | Signature validation failed" -Foreground Red
            }
        }

    }    
}


function Test-Validate-AadToken
{
    $token = Get-AadTokenUsingAdal -ClientId 'AadSupport UnitTest' -ResourceId 'https://graph.windows.net'

    # Provide no issuer
    Validate-AadToken -JwtToken $token.AccessToken

    # Provide B2C issuer
    Validate-AadToken -JwtToken $token.AccessToken -Issuer "https://williamfiddesb2c.b2clogin.com/tfp/williamfiddesb2c.onmicrosoft.com/B2C_1_V2_SUSI_DefaultPage/v2.0/.well-known/openid-configuration"

}



