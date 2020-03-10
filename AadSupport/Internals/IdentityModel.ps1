$token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkhsQzBSMTJza3hOWjFXUXdtak9GXzZ0X3RERSIsImtpZCI6IkhsQzBSMTJza3hOWjFXUXdtak9GXzZ0X3RERSJ9.eyJhdWQiOiIwMDAwMDAwMi0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDAiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9hYTAwZDFmYS01MjY5LTRlMWMtYjA2ZC0zMDg2ODM3MWQyYzUvIiwiaWF0IjoxNTgzODA4MzI0LCJuYmYiOjE1ODM4MDgzMjQsImV4cCI6MTU4MzgwOTIyNCwiYWNyIjoiMSIsImFpbyI6IjQyTmdZRGh2K2U1b2F4dmZFc0c5eGxKQ2hrN2l1MTRyMnA3cFVaRzRZbURuZUcwR2J3QUEiLCJhbXIiOlsicHdkIl0sImFwcGlkIjoiODMyNThiYzctYjdmZC00NjI3LWFlOWItZTNiZDVkNTUwNTcyIiwiYXBwaWRhY3IiOiIwIiwiZmFtaWx5X25hbWUiOiJBY2NvdW50IiwiZ2l2ZW5fbmFtZSI6IkFkbWluaXN0cmF0b3IiLCJpcGFkZHIiOiI0Ny4xODQuNTEuMjQiLCJuYW1lIjoiQWRtaW4gQWNjb3VudCIsIm9pZCI6IjQzYTU0ODhjLTlkZTYtNDJlNS1hYmRlLTNjYjM0ZThmMGVkYyIsInB1aWQiOiIxMDAzN0ZGRTg0QzhFNjI0Iiwic2NwIjoiQ2FsZW5kYXJzLlJlYWQgRGlyZWN0b3J5LlJlYWQuQWxsIGVtYWlsIEZpbGVzLlJlYWRXcml0ZSBNYWlsLlNlbmQgb2ZmbGluZV9hY2Nlc3Mgb3BlbmlkIHByb2ZpbGUgU2l0ZXMuUmVhZC5BbGwgVGFza3MuUmVhZCBVc2VyLlJlYWQgVXNlci5SZWFkLkFsbCBVc2VyQWN0aXZpdHkuUmVhZFdyaXRlLkNyZWF0ZWRCeUFwcCIsInN1YiI6IjRUTk1Ea2ZUYVc4ZjBQTHZ6QnB3VlR2V05vbWV1MEZpZi05Tmt4eXhWOTAiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiTkEiLCJ0aWQiOiJhYTAwZDFmYS01MjY5LTRlMWMtYjA2ZC0zMDg2ODM3MWQyYzUiLCJ1bmlxdWVfbmFtZSI6ImFkbWluQHdpbGxpYW1maWRkZXMub25taWNyb3NvZnQuY29tIiwidXBuIjoiYWRtaW5Ad2lsbGlhbWZpZGRlcy5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJWSXAyLTNkdDVFLXhYcWRnNG40QkFBIiwidmVyIjoiMS4wIn0.tCCN1oLtRMDEGUbTBuo4xlFz1mTX_5BubQhWYKRPf6rNSB0YyDM1PFJa53BbeB2i-fQwkrTpgJ-JB2GsitmGdAZ5w-hnWVcBx9e-nJuRC7fSzl52hUBHKs8vmXy7XJhAgWNOLAC5qvg7CG4t-UXVo_YkgarydpXtqli_2AOIiaG0-qvwId1daD2ev_DpjVek-RNubz8EeKAhFDkUDlO4X5tRCK1ocEjJywZgluorbzTsGC0FHdGwI460SS040EFjux5qM4AMh6AW2x7epSR4fMFIdcjtiFOT6xFc7cNs3SHOc83r7ZT4Ul3Fp_mQjoHoDBUyQSkZqYVE3tCjXeffpg"


function ValidateToken
{
    Param($SignedToken, $SigningKey)
    $tokenParts = $SignedToken.Split('.')
  
    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $rsaParameters = [System.Security.Cryptography.RSAParameters]::new()
    $rsaParameters.Modulus = FromBase64Url -base64Url $SigningKey.n
    $rsaParameters.Exponent = FromBase64Url -base64Url $SigningKey.e

    $rsa.ImportParameters($rsaParameters)
  
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($tokenParts[0] + '.' + $tokenParts[1]))
  
    $rsaDeformatter = [System.Security.Cryptography.RSAPKCS1SignatureDeformatter]::new($rsa)
    $rsaDeformatter.SetHashAlgorithm("SHA256")
    $TokenSignatureBytes = FromBase64Url -base64Url $tokenParts[2]
    if ($rsaDeformatter.VerifySignature($hash, $TokenSignatureBytes))
    {
        Write-Host "Signature is verified"
    }

    else
    {
        Write-Host "Signature validation failed" -forgrouncolor Red
    }
}


function FromBase64Url([string] $base64Url)
{
    if($base64Url.Length % 4 -eq 0)
    {
        $padded = $base64Url
    }
    else
    {
        $padded = $base64Url + "====".Substring($base64Url.Length % 4)
    }
 
    $base64 = $padded.Replace("_", "/").Replace("-", "+")
    return [System.Convert]::FromBase64String($base64)
}

function GenerateSignature
{
    Param(
        [string] $UnsignedToken,
        [byte[]] $SigningKey
    )

    $hmac = [System.Security.Cryptography.SHA256]::new($SigningKey)
    
    [byte[]] $signatureBytes = $hmac.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($UnsignedToken))
    $signature = [System.Web.HttpUtility]::UrlEncode([System.Convert]::ToBase64String($signatureBytes))

    return $signature
}

function GetUnsignedToken
{
    Param([string]$SignedToken)

    $TokenParts = $SignedToken.Split(".")

    try {
        return $TokenParts[0] + "." + $TokenParts[1]
    }

    catch {
        return "Invalid Json Web Token."    
    }
}

#$UnsignedToken = GetUnsignedToken -SignedToken $token
#$TokenSignature = $token.Split(".")[2]

$SigningKeys = Get-AadDiscoveryKeys
$SigningKey = $SigningKeys[1]

#$GeneratedSignature = GenerateSignature -UnsignedToken $UnsignedToken -SigningKey $SigningKey


ValidateToken -SignedToken $token -SigningKey $SigningKey
