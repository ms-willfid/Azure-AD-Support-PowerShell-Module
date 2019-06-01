function AadSupportLog
{
    param([switch]$Output, $Object)
    
    if($Output)
    {
        foreach($member in $Object)
        {
            Write-Verbose $member
        }
    }

}