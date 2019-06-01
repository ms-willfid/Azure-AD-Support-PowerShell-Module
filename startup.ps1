Write-Host ""
Write-Host "For more information about the 'Azure AD Support PowerShell Module' (AadSupport)..." -ForegroundColor Yellow
Write-Host "https://github.com/ms-willfid/aad-support-psh-module" -ForegroundColor Yellow

# Import the internal functions
$scripts = Get-ChildItem -Path $PSScriptRoot\Internals\*.ps1
foreach($script in $scripts) {
    . $script.FullName
}

# Check if update is available
$remote_module = Find-Module -Name AadSupport
$local_module = Get-Module -ListAvailable -Name AadSupport
if ($remote_module.Version -ne $local_module.Version.toString()) {
    Write-Host ""
    Write-Host "There is a update available for AadSupport" -ForegroundColor Yellow
    Write-Host "Run 'Update-Module -Name AadSupport -Force -AllowClobber'"
}

# Check if Azure AD PowerShell is installed
$module = Get-Module -ListAvailable -Name AzureAd
$modulep = Get-Module -ListAvailable -Name AzureAdPreview
$AzureModule = Get-Module -ListAvailable -Name Az.Accounts

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
    Write-Host ""
    Write-Host "AzureAD PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install AzureAD PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module AzureAd -Force -AllowClobber
        Write-Host "Finished installing AzureAD Module"
    }

    catch {
        throw "Unable to install AzureAD PowerShell module. Please run PowerShell as a Administrator."
    }
}

# Check if Azure  PowerShell is installed
if(-not $AzureModule) {
    Write-Host ""
    Write-Host "(Az)ure PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install (Az)ure PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module Az -Force -AllowClobber
        Write-Host "Finished installing (Az)ure Module"
    }

    catch {
        throw "Unable to install (Az)ure PowerShell module. Please run PowerShell as a Administrator."
    }
}

#Get the module folder so we can load the ADAL DLLs we want
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
    Write-Warning "Unable to load ADAL assemblies.`nUpdate the AzureAd module by running Install-Module AzureAd -Force -AllowClobber"
    Throw $error[0]
}
        

$Global:AadSupportModule = $true

