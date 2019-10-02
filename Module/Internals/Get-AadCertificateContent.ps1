function Get-AadCertificateContent( $Content )
 {

    # Testing arguments
    #$section = "PRIVATE KEY"

    $header = "-----BEGIN"
    
    $footer = "-----END"

    $HeaderStart = $Content.IndexOf("-----", [System.StringComparison]::Ordinal)
    $HeaderEnd   = $Content.IndexOf("-----", ($HeaderStart+1), [System.StringComparison]::Ordinal)
    $FooterStart = $Content.IndexOf("-----", ($HeaderEnd+1), [System.StringComparison]::Ordinal)
    $FooterEnd   = $Content.IndexOf("-----", ($FooterStart+1), [System.StringComparison]::Ordinal)

    if( $HeaderStart -lt 0 ) 
    {
        Write-Verbose "NOT FOUND!" 
        return $null
    }

    $start = $HeaderEnd+5;
    $end = $FooterStart -$start

    if( $end -lt 0 )
       { return $null }

    return $pemSubstring = $Content.Substring( $start, $end )
 }