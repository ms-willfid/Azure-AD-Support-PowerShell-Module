function New-AadSupportSession
{
        
    $Global:AadSupport = [hashtable]::Synchronized(@{
        Path = $PSScriptRoot
        ClientId = "a57bfff5-9e23-439d-9993-48d76ba688ca"
        RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
        Logging = @{
            Enabled = $false
            Path = "c:/AadSupport/"
            FileName = ""
        }
    
        Powershell = @{
            Modules = @{
                AzureAd = @{
                    Name = $null
                    Version = $null
                }
    
                Azure = @{
                    Name = $null
                    Version = $null
                }
            }
        }
    
        Session = @{
            AadInstance = $null
            TenantId = $null
            TenantDomain = $null
            AccountId = $null
            Active = $false
            AzureEnvironmentName = "AzureCloud"
            AzureAccessToken = $null
            AzureGraphToken = $null
            AadAccessToken = $null
        }
    
        Runspace = @{
            AzureAd = @{
                Instance = [runspacefactory]::CreateRunspace()
                Connected = $false
            }
            MSOnline = @{
                Instance = [runspacefactory]::CreateRunspace()
                Connected = $false
            }
            Adal = @{
                Instance = [runspacefactory]::CreateRunspace()
            }
    
        }
    
        Common = @{
            AadInstance = "https://login.microsoftonline.com"
            TenantId = "common"
        }
    
        Clients = @{
            AzureAdPowerShell = @{
                ClientId = "1b730954-1685-4b74-9bfd-dac224a7b894"
                RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
            }
            AzurePowerShell = @{
                ClientId = "1950a258-227b-4e31-a9cf-717495945fc2"
                RedirectUri = "urn:ietf:wg:oauth:2.0:oob"
            }
        }
    
        Resources = @{
            AadGraph = "https://graph.windows.net"
            MsGraph = "https://graph.microsoft.com"
            AzureRmApi = "https://management.azure.com"
            AzureServiceApi = "https://management.core.windows.net"
            KeyVault = "https://vault.azure.net"
        }
    })
}

New-AadSupportSession

Write-Host ""
Write-Host "For more information about the 'Azure AD Support PowerShell Module' (AadSupport)..." -ForegroundColor Yellow
Write-Host "https://github.com/ms-willfid/aad-support-psh-module" -ForegroundColor Yellow

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


# Check AzureAd
if ($module)
{
    $ModuleName = "AzureAD"
    $ModuleVersion = $module.Version.ToString()
    if($ModuleVersion -lt "2.0.2.76")
    {
        Write-Host ""
        Write-Host "Please update your AzureAd PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAd -Force -AllowClobber'" -ForegroundColor Yellow
    }
}

# Check AzureAdPreview
if ($modulep)
{
    $ModuleName = "AzureADPreview"
    $ModuleVersion = $modulep.Version.ToString()
    if($ModuleVersion -lt "2.0.2.85")
    {
        Write-Host ""
        Write-Host "Please update your AzureAdPreview PowerShell Module..." -ForegroundColor Yellow
        Write-Host "Run... 'Install-Module AzureAdPreview -Force -AllowClobber'" -ForegroundColor Yellow
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

$Global:AadSupport.Powershell.Modules.AzureAd.Name = $ModuleName
$Global:AadSupport.Powershell.Modules.AzureAd.Version = $ModuleVersion


# Check Azure PowerShell is updated
if ($AzureModule)
{
    if($AzureModule.Version.ToString() -lt "2.7.0")
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

# GET ADAL INFO
#Get the module folder so we can load the ADAL DLLs we want
$modulebase = (Get-Module $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$Global:AadSupportAdalPath = $AdalPath = "{0}\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -f $modulebase
$adalVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($Global:AadSupportAdalPath).FileVersion)

# Import the internal functions
$scripts = Get-ChildItem -Path $PSScriptRoot\Internals\*.ps1
foreach($script in $scripts) {
    . $script.FullName
}

# Import Logging function
$LogScript = "$PSScriptRoot\Internals\imports\Log-AadSupport.ps1"
. $LogScript

Load-AadSupportAdalAssembly

"ADAL Version: $adalVersion" | Log-AadSupport
"ADAL Path: $AdalPath" | Log-AadSupport

$Global:AadSupportModule = $true


# EXTENSION HELPER METHOS

