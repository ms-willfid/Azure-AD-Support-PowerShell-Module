# ############################################################################
Function Convert-AadThumbprintToByteArray {
    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true)]
        [String] $Thumbprint
    )

    Write-Verbose "Converting thumbrpint '$Thumbprint' to ByteArray" 

    $Bytes = [byte[]]::new($Thumbprint.Length / 2)

    For($i=0; $i -lt $Thumbprint.Length; $i+=2){
        $Bytes[$i/2] = [convert]::ToByte($Thumbprint.Substring($i, 2), 16)
    }

    return $Bytes
}

# ############################################################################
Function Convert-ByteArrayToThumbprint {

    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [Byte[]]
        $Bytes
    )

    $Thumbprint = [System.Text.StringBuilder]::new($Bytes.Length * 2)

    ForEach($byte in $Bytes){
        $Thumbprint.AppendFormat("{0:x2}", $byte) | Out-Null
    }

    return $Thumbprint.ToString()
}


function Base64UrlEncode($Value)
{
    return $Value.Replace("=", [String]::Empty).Replace('+', '-').Replace('/', '_')
}

function Base64UrlDecode($Value)
{
    while($Value.Length % 4 -ne 0)
    {
        $Value += "="
    }
    
    return $Value.Replace('-', '+').Replace('_', '/')

}


function ConvertFrom-Base64String
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$base64string
    )

    return [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($base64string)))
}