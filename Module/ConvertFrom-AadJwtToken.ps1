<#
.SYNOPSIS
Convert a base64Encoded Json Web Token to a PowerShell object.
#

.DESCRIPTION
Convert a base64Encoded Json Web Token to a PowerShell object.

.PARAMETER Token
Parameter description

.EXAMPLE
EXAMPLE 1
"eyJ***" | ConvertFrom-AadJwtToken

EXAMPLE 2
ConvertFrom-AadJwtToken -Token "eyJ***"

.NOTES
General notes
#>

function ConvertFrom-AadJwtToken {
 
    [cmdletbinding()]
    param([Parameter(ValueFromPipeline = $true,Mandatory=$true)][string]$Token)
 
    #Validate as per https://tools.ietf.org/html/rfc7519
    #Access and ID tokens are fine, Refresh tokens will not work
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
    
    $jwtClaims = [ordered]@{}

    #Header
    $tokenheader = $token.Split(".")[0]
    
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) { $tokenheader += "=" }
    
    #Convert from Base64 encoded string to PSObject all at once
    $jwtHeader = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json)

    $jwtHeader.psobject.properties | Foreach { $jwtClaims[$_.Name] = $_.Value }

    #Payload
    $tokenPayload = $token.Split(".")[1]
    
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenPayload.Length % 4) { $tokenPayload += "=" }
    
    #Convert from Base64 encoded string to PSObject all at once
    $jwtPayload = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenPayload)) | ConvertFrom-Json)

    $claims = $jwtPayload.psobject.properties

    
    Foreach ($claim in $claims) 
    { 
        if($claim.Name -eq "iat" -or $claim.Name -eq "exp" -or $claim.Name -eq "nbf") 
        {
            $jwtClaims.Add($claim.Name, ($claim.Value | ConvertFrom-AadJwtTime) )
        }

        else 
        { 
            $jwtClaims.Add($claim.Name,$claim.Value)
        }


    }

    $Object = New-Object -TypeName psobject -Property $jwtClaims

    return $Object
}