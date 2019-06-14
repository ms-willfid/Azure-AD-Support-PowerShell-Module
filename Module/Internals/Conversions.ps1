# ############################################################################
Function Convert-ThumbprintToByteArray {

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