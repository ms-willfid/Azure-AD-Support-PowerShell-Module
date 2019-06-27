<#
.SYNOPSIS
Convert the long number format from JWT tokens to UTC

.DESCRIPTION
Convert the long number format from JWT tokens to UTC
For example convert '1557162946' to '2019-05-06T22:15:46.0000000Z'

.PARAMETER JwtNumberDateTime
This is the JWT number format (i.e. 1557162946)

.EXAMPLE
ConvertFrom-AadJwtTime 1557162946

.NOTES
General notes
#>

function ConvertFrom-AadJwtTime {
    Param (
        [Parameter(ValueFromPipeline = $true,Mandatory=$true)]
        [string]
        $JwtDateTime
    )

    $date = (Get-Date -Date "1/1/1970").AddSeconds($JwtDateTime)
    return $date
}