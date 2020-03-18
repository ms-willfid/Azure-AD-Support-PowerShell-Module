function Load-AadSupportAdalAssembly
{
    
    param(
        [string]$AdalPath = $Global:AadSupportAdalPath
    )


    #Attempt to load the assemblies. Without these we cannot continue so we need the user to stop and take an action

    Try
    {
        
        $Params = @{
            PSScriptRoot = $PSScriptRoot
            AadSupportAdalPath = $Global:AadSupportAdalPath
        }

        Invoke-AdalCommand -Command {
            Param($Params)
            [System.Reflection.Assembly]::LoadFrom($Params.AadSupportAdalPath) | Out-Null
        } -Parameters $Params

        Invoke-AdalCommand -Command {
            Param($Params)
            . "$($Params.PSScriptRoot)\ADAL\Adal.Class.ps1" 
        } -Parameters $Params 
    }

    Catch
    {
        Write-Warning "Unable to load ADAL assemblies.`nUpdate the AzureAd module by running Install-Module AzureAd -Force -AllowClobber"
    }


    
} 


