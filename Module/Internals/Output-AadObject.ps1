function Output-AadObject
{
    param
    (
        $InputObject
    )

    $ReportItem = @{}
    foreach($Member in ($InputObject | Get-Member))
    {
        if($Member.MemberType -eq "NoteProperty" -or $Member.MemberType -eq "Property")
        {
            $MemberName = $null
            $MemberName = $Member.Name
            $Value = $InputObject.$($MemberName)
            if($Value)
            {
                $Type = $null
                $Type = $InputObject.$($MemberName).GetType()
                if($Type.isArray)
                {
                    $ReportItem.($MemberName) = $InputObject.($MemberName) | ConvertTo-Json -Compress -Depth 99
                }

                else {
                    $ReportItem.($MemberName) = $InputObject.($MemberName)
                }
            }
        }
    }

    return $ReportItem
}