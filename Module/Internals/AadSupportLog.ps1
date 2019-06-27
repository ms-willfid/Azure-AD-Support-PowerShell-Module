class AadSupportLog {

    [string]$LogPath = "$PSScriptRoot\Logs\AadSupportLog.txt"

    Info([string]$msg) {
        $datetime = [System.DateTime]::UtcNow
        Write-Output "$datetime INFO $msg" | Out-File $this.LogPath -Append
    }

    Error([string]$msg) {
        $datetime = [System.DateTime]::UtcNow
        Write-Output "$datetime ERROR $msg" | Out-File $this.LogPath -Append
    }
}