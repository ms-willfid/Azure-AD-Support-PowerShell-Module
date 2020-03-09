function Log-AadSupportMessage
{
    Param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        $Message,
        [switch]$Force
    )

    if(-not $Message) {
        return
    }

    if(-not $GlobalParams -and $Global:AadSupport)
    {
        $GlobalParams = $Global:AadSupport
    }

    if($GlobalParams.Logging.Enabled -or $Force)
    {
        if($Message.GetType().ToString() -eq "System.Collections.Hashtable")
        {
            $Message = $Message | ConvertTo-Json
        }

        $LogFileName = $GlobalParams.Logging.FileName
        $LogPath = $GlobalParams.Logging.Path
        $Now = (Get-Date).ToUniversalTime()
        $Utc = Get-Date $Now -Format o
        $date = ($Utc).Replace(":","-").Replace(".","_")

        if(-not $LogFileName)
        {
            $LogFileName = "$($date.ToString()).txt"
            New-Item -Path $LogPath -Name $LogFileName -ItemType "file" -Force | Out-Null
            $GlobalParams.Logging.FileName = $LogFileName
        }

        $FullPath = "$LogPath/$LogFileName"

        Add-Content -Path $FullPath -Value "$date | " -Force -NoNewline
        Add-Content -Path $FullPath -Value $Message -Force
    }

}