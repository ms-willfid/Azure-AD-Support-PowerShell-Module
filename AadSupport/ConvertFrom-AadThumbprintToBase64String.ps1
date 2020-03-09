<#
.SYNOPSIS
Converts a Base64Encoded Thumbprint or also known as Key Identifier (Kid) back to its original Thumbprint value

.DESCRIPTION
Converts a Base64Encoded Thumbprint or also known as Key Identifier (Kid) back to its original Thumbprint value

.PARAMETER Base64String
Base64Encoded version of the Thumbprint

.EXAMPLE
ConvertFrom-AadBase64StringToThumbprint -Base64String 'z79RnGljTQa9Zh4ZjLq6UaB4eUM='

Output...
CF-BF-51-9C-69-63-4D-06-BD-66-1E-19-8C-BA-BA-51-A0-78-79-43

.NOTES
#>

Function ConvertFrom-AadThumbprintToBase64String {

    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true)]
        [String]
        $Thumbprint
    )

    $Bytes = Convert-ThumbprintToByteArray -Thumbprint ($Thumbprint.Replace("-",""))

    $hashedString =[Convert]::ToBase64String($Bytes)

    return $hashedString
}