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
if ($local_module -and $remote_module.Version -ne $local_module.Version.toString()) {
    Write-Host ""
    Write-Host "There is a update available for AadSupport" -ForegroundColor Yellow
    Write-Host "Run the following command... 'Update-AadSupport'"
}

# Check if required PowerShell modules are installed
$module = Get-Module -ListAvailable -Name AzureAd
$modulep = Get-Module -ListAvailable -Name AzureAdPreview
$AzureModule = Get-Module -ListAvailable -Name Az.Accounts
$MsolModule = Get-Module -ListAvailable -Name MsOnline

# Check AzureAdPreview
if ($modulep)
{
    $ModuleName = "AzureADPreview"
    if($modulep.Version.ToString() -lt "2.0.2.17")
    {
        Write-Host ""
        Write-Host "Please update your AzureAdPreview PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAdPreview -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check AzureAd
if ($module)
{
    $ModuleName = "AzureAD"
    if($module.Version.ToString() -lt "2.2.0.16")
    {
        Write-Host ""
        Write-Host "Please update your AzureAd PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAd -Force -AllowClobber'" -ForegroundColor Yellow
    }
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


# Check Azure PowerShell is updated
if ($AzureModule)
{
    if($AzureModule.Version.ToString() -lt "2.2.0")
    {
        Write-Host ""
        Write-Host "Please update your Az PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module Az -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check if Azure  PowerShell is installed
elseif(-not $AzureModule) {
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

# Check MSOnline PowerShell is updated
if ($MsolModule)
{
    if($MsolModule.Version.ToString() -lt "1.1.166.0")
    {
        Write-Host ""
        Write-Host "Please update your MSOnline PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module MSOnline -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check if MSOnline PowerShell is installed
elseif(-not $MsolModule) {
    Write-Host ""
    Write-Host "MSOnline PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install MSOnline PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module Az -Force -AllowClobber
        Write-Host "Finished installing MSOnline Module"
    }

    catch {
        throw "Unable to install MSOnline PowerShell module. Please run PowerShell as a Administrator."
    }
}

# LOAD ADAL ASSEMBLY

#Get the module folder so we can load the ADAL DLLs we want
$modulebase = (Get-Module $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$Global:AadSupportAdalPath = "{0}\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -f $modulebase
$adalVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($Global:AadSupportAdalPath).FileVersion)
Write-Verbose "ADAL Module Path: $($Global:AadSupportAdalPath)"
Write-Verbose "ADAL Version: $adalVersion" 

#Attempt to load the assemblies. Without these we cannot continue so we need the user to stop and take an action
Load-AadSupportAdalAssembly

$Global:AadSupportModule = $true

