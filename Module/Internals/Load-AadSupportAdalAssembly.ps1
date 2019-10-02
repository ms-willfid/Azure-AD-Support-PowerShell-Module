function Load-AadSupportAdalAssembly
{
    param(
        [string]$AdalPath = $Global:AadSupportAdalPath
    )

    Try
    {
        $Global:AadSupportAdalAssembly = [System.Reflection.Assembly]::LoadFrom($AdalPath)
    }
    Catch
    {
        Write-Warning "Unable to load ADAL assemblies.`nUpdate the AzureAd module by running Install-Module AzureAd -Force -AllowClobber"
    }
} 