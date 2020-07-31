<#
.SYNOPSIS
Generates a client assertion for Azure AD.

.DESCRIPTION
Generates a client assertion for Azure AD. Requires a PFX with a Private Key. 

You can create one using "New-AadApplicationCertificate"

.PARAMETER ClientId
Specify the Azure AD application this client assertion is meant for.

.PARAMETER CertificatePath
Path to certificate (PFX)

.PARAMETER CertificatePassword
Password for the PFX

.PARAMETER Tenant
Specify the tenant name or ID this client assertion is meant for.

.EXAMPLE
New-AadClientAssertion -ClientId ac4dff1b-b7d7-4453-a4e4-613210c686c9 -CertificatePath "C:\path\to\certificate.pfx" -CertificatePassword "SomePassword" -Tenant contoso.onmicrosoft.com

.NOTES

.RELATED
https://github.com/AzureAD/microsoft-authentication-library-for-dotnet/wiki/Client-Assertions

#>

function New-AadClientAssertion
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(mandatory=$true)]
        $ClientId,

        [Parameter(mandatory=$true)]
        [string]$CertificatePath,

        [Parameter(mandatory=$true)]
        [string]$CertificatePassword,

        [Parameter(mandatory=$true)]
        [string]$Tenant  
    )


    if(![System.IO.Path]::IsPathRooted($CertificatePath))
    {
        $LocalPath = Get-Location
        $CertificatePath = "$LocalPath\$CertificatePath"
    }

    Write-Verbose "Looking for $CertificatePath"

    $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($CertificatePath, $CertificatePassword)


    $ThumbprintBase64 = ConvertFrom-AadThumbprintToBase64String $certificate.Thumbprint
    
    $nbf = [int][double]::parse((Get-Date -Date $(Get-Date).ToUniversalTime() -UFormat %s))
    $exp = [int][double]::parse((Get-Date -Date $((Get-Date).addseconds($ValidforSeconds).ToUniversalTime()) -UFormat %s)) # Grab Unix Epoch Timestamp and add desired expiration.
    $jti = New-Guid
    $aud = "https://login.microsoftonline.com/$Tenant/oauth2/token"
    $sub = $ClientId
    $iss = $ClientId
   
    [hashtable]$header = @{
        alg = "RS256"; 
        typ = "JWT"; 
        x5t = $ThumbprintBase64; 
        kid = $ThumbprintBase64 
    }

    [hashtable]$payload = @{
        aud = $aud; 
        iss = $iss; 
        sub = $sub; 
        jti = $jti; 
        nbf = $nbf; 
        exp = $exp; 
        tid = "aa00d1fa-5269-4e1c-b06d-30868371d2c5";
    }

    $headerjson = $header | ConvertTo-Json -Compress
    $payloadjson = $payload | ConvertTo-Json -Compress
    
    $headerjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($headerjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    $payloadjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payloadjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')

    $ToBeSigned = [System.Text.Encoding]::UTF8.GetBytes($headerjsonbase64 + "." + $payloadjsonbase64)


    $rsa = $certificate.PrivateKey
    if ($null -eq $rsa) { # Requiring the private key to be present; else cannot sign!
        throw "There's no private key in the supplied certificate - cannot sign" 
    }
    else {
        # Overloads tested with RSACryptoServiceProvider, RSACng, RSAOpenSsl
        try { $Signature = [Convert]::ToBase64String($rsa.SignData([byte[]]$ToBeSigned,[Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1)) -replace '\+','-' -replace '/','_' -replace '=' }
        catch 
        {
            throw "Signing with SHA256 and Pkcs1 padding failed using private key $rsa >> " + $_
        }
    }

    $token = "$headerjsonbase64.$payloadjsonbase64.$Signature"

    Write-Host "Generated Client Assertion..."
    return $token

}