
<#
.SYNOPSIS
Azure AD uses the UTC time (Coordinated Universal Time) and Universal Sortable DateTime Pattern.

.DESCRIPTION
Azure AD uses the UTC time (Coordinated Universal Time) and Universal Sortable DateTime Pattern.

UTC is the worlds synchronized time and set to the GMT time zone.
Universal Sortable DateTime Pattern looks like this: yyyy-MM-dd'T'HH:mm:ss.SSSZ

.PARAMETER DateTime
Specify DateTime you want to convert to UTC

.PARAMETER AddDays
Add or subtract days from current DateTime or specified DateTime

.PARAMETER AddHours
Add or subtract hours from current DateTime or specified DateTime

.PARAMETER AddMinutes
Add or subtract minutes from current DateTime or specified DateTime

.EXAMPLE
Get-AadDateTime
Get-AadDateTime -DateTime "01/20/2019"
Get-AadDateTime -AddDays 7 -AddHours 12 -AddMinutes 30
Get-AadDateTime -DateTime "01/20/2019" -AddDays -7

.NOTES
General notes
#>

function Get-AadDateTime {
    param 
    (
        [Parameter(
            mandatory=$false,
            ValueFromPipeline = $true)]
        $DateTime, 
        $AddDays, 
        $AddHours, 
        $AddMinutes,
        $AddYears,
        $AddMonths
    )

    if ($DateTime) 
    {
        $date = (Get-Date $DateTime).ToUniversalTime()
    }
    
    else
    {
        $date = (Get-Date).ToUniversalTime()
    }

    if ($AddDays) {
        $date = $date.AddDays($AddDays)
    }

    if ($AddHours) {
        $date = $date.AddHours($AddHours)
    }

    if ($AddMinutes) {
        $date = $date.AddMinutes($AddMinutes)
    }

    if ($AddYears) {
        $date = $date.AddYears($AddYears)
    }

    if ($AddMonths) {
        $date = $date.AddMonths($AddMonths)
    }

    return (Get-Date $date -Format o)
}