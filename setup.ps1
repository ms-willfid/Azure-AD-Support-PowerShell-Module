Write-Host "For more information about the 'Azure AD Support PowerShell Module' (AadSupport)..." -ForegroundColor Yellow
Write-Host "https://github.com/ms-willfid/aad-support-psh-module" -ForegroundColor Yellow

$Global:AadSupportModule = $true

# Check if Azure AD PowerShell is installed
$module = Get-Module -ListAvailable -Name AzureAd
$modulep = Get-Module -ListAvailable -Name AzureAdPreview

if ($module -and -not $modulep)
{
    Write-Host "You have AzureAd module installed, however AzureAdPreview is required" -ForegroundColor Yellow
    Write-Host "0. You will need to run PowerShell as an administrator." -ForegroundColor Yellow
    Write-Host "1. Please Uninstall AzureAd module using 'Uninstall-Module AzureAd'" -ForegroundColor Yellow
    Write-Host "2. Then install AzureAdPreview using 'Install-Module AzureAdPreivew'" -ForegroundColor Yellow
    return
}

# Install Azure AD PowerShell if not installed
elseif (-not $module -and -not $modulep) {
    Write-Host "Azure AD Preview PowerShell module not installed!" -ForegroundColor Yellow
    Write-Host "Attempting to install Azure AD Preview PowerShell module..." -ForegroundColor Yellow
    try {
        Install-Module AzureAdPreview
    }

    catch {
        throw "Unable to install Azure AD Preview PowerShell module. Please run PowerShell as a Administrator."
    }
}