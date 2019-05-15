Write-Host "For more information about the 'Azure AD Support PowerShell Module' (AadSupport)..." -ForegroundColor Yellow
Write-Host "https://github.com/ms-willfid/aad-support-psh-module" -ForegroundColor Yellow


$Global:AadSupportModule = $true

# Check if Azure AD PowerShell is installed
$module = Get-Module -ListAvailable -Name AzureAd
$modulep = Get-Module -ListAvailable -Name AzureAdPreview

if ($modulep)
{
    $ModuleName = "AzureADPreview"
}

if ($module)
{
    $ModuleName = "AzureAD"
}

# Install Azure AD PowerShell if not installed
elseif (-not $module -and -not $modulep) {
    Write-Host "Azure AD PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install Azure AD Preview PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module AzureAd
    }

    catch {
        throw "Unable to install Azure AD PowerShell module. Please run PowerShell as a Administrator."
    }
}


#Import the AzureAD module so we can lookup the directory for Microsoft.IdentityModel.Clients.ActiveDirectory.dll
#MSOnline module documentation: https://www.powershellgallery.com/packages/MSOnline/1.1.166.0

#Get the module folder so we can load the DLLs we want
$modulebase = (Get-Module $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$adalpath = "{0}\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -f $modulebase
$adalVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo("$adalpath").FileVersion)
Write-Verbose "ADAL Module Path: $adalpath"
Write-Verbose "ADAL Version: $adalVersion" 
#Attempt to load the assemblies. Without these we cannot continue so we need the user to stop and take an action
Try
    {
        $AdalAssembly = [System.Reflection.Assembly]::LoadFrom($adalpath)
    }
Catch
    {
        Write-Warning "Unable to load ADAL assemblies.`nUpdate the AzureAd module by running Install-Module AzureAdPreview -Force -AllowClobber"
        Throw $error[0]
    }
        