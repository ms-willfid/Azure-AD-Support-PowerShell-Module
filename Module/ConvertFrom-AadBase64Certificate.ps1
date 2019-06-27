<#
.SYNOPSIS
Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability

.DESCRIPTION
Converts a single Base64Encoded certificate (Not Chained Ceritificate) to a Custom PSObject for easy readability


.PARAMETER Base64String
The Base64Encoded Certificate

.EXAMPLE
ConvertFrom-AadBase64Certificate -Base64String "MIIHkDCCBnigAwIBAgIRALENqydLHXg/u+VM04+dg2QwDQYJKoZIhvcNAQELBQAwgZ..."

.NOTES
General notes
#>

function ConvertFrom-AadBase64Certificate

{
    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [String]
        $Base64String
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Base64String)
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$bytes)
    $kid = ConvertFrom-AadThumbprintToBase64String -Thumbprint $cert.Thumbprint
    
    $Properties = @{ 
        Kid = $kid; 
        Thumbprint = $cert.Thumbprint;
        NotAfter = $cert.NotAfter;
        NotBefore = $cert.NotBefore; 
        Subject = $cert.Subject;
        Issuer = $cert.Issuer;
        Certificate = $cert;
    }

    $Object = new-object PSObject -Property $Properties

    return $Object
}