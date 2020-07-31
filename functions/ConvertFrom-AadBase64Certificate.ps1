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
    [cmdletbinding(DefaultParameterSetName="Default")]
    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ParameterSetName="Default")]
        [String]
        $Base64String,

        [parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ParameterSetName="Path")]
        [String]
        $Path,

        [String]$Password
    )

    if($Path -and ![System.IO.Path]::IsPathRooted($Path))
    {
        $LocalPath = Get-Location
        $Path = "$LocalPath\$Path"
    }


    if($Path)
    {
        $bytes = [System.IO.File]::ReadAllBytes("$path")
    }

    if($Base64String)
    {
        # Sometimes a Base64Encoded Cert has been Base64Encoded again (Chained Certs)
        if(-not $Base64String.StartsWith("MII") -and -not $Base64String.StartsWith("-----BEGIN"))
        {
            $Base64String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String));
        }

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Base64String)
    }
    
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($bytes,$Password)
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