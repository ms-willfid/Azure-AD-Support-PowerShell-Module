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

function Get-AadTrustedSites
{
    $CurrentLocation = Get-Location
    $Key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\domains"
    TraverseKey -Key $Key

    Set-Location -Path $CurrentLocation
}

function TraverseKey
{
    Param(
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline = $true)]
        [string]$Key
    )

    $Key = $Key.Replace("HKEY_CURRENT_USER","HKCU:")

    $items = Get-ChildItem -Path $Key
    $items
    
    $Sites = @()

    foreach($item in $items)
    {
        $itemName = $item.Name.Replace("HKEY_CURRENT_USER","HKCU:")
        if($Key -eq $itemName)
        {
            continue
        }

        TraverseKey -Key $item.Name
    }

}