<#
.SYNOPSIS
Converts a Thumbprint to a Base64Encoded Thumbprint or also known as Key Identifier (Kid)

.DESCRIPTION
Converts a Thumbprint to a Base64Encoded Thumbprint or also known as Key Identifier (Kid)

.PARAMETER Thumbprint
Provide the Thumbprint to be converted to a Base64Encoded value

.EXAMPLE
ConvertFrom-AadThumbprintToBase64String -Base64String 'CF-BF-51-9C-69-63-4D-06-BD-66-1E-19-8C-BA-BA-51-A0-78-79-43' 
ConvertFrom-AadThumbprintToBase64String -Base64String 'CFBF519C69634D06BD661E198CBABA51A0787943'

Output...
z79RnGljTQa9Zh4ZjLq6UaB4eUM=

.NOTES
#>

Function ConvertFrom-AadThumbprintToBase64String {

    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [String] $Thumbprint
    )

    $Bytes = Convert-ThumbprintToByteArray -Thumbprint ($Thumbprint.Replace("-",""))

    $hashedString =[Convert]::ToBase64String($Bytes)

    return $hashedString
}