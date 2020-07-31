
<#
.SYNOPSIS
Utility to convert strings to Base 64 Encoded Strings. By default this will also remove formatting from 'Carriage Return', 'New Line', 'Tab'

.DESCRIPTION
Utility to convert strings to Base 64 Encoded Strings. By default this will also remove formatting from 'Carriage Return', 'New Line', 'Tab'

ConvertTo-AadBase64EncodedString -string 'your-string-here' -StripFormatting $true

.PARAMETER String
String to encode to Base 64.

.PARAMETER StripFormatting
Boolean to determine if formatting items like ('Carriage Return', 'New Line', 'Tab') should be removed.
Default is TRUE. Formatting items will be removed.

.EXAMPLE
ConvertTo-AadBase64EncodedString -string 'your-string-here' -StripFormatting $true


.NOTES
General notes
#>
function ConvertTo-AadBase64EncodedString
{

    Param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        [string]$String,
        [bool]$StripFormatting=$true
    )


    if($StripFormatting)
    {
        $String = $String.Replace("`r", "").Replace("`n", "").Replace("`t", "")
    }

    $EncodedString = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
    
    return $EncodedString
}