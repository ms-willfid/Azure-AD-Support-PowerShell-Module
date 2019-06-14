<#
.SYNOPSIS
Updates the AadSupport PowerShell Module

.DESCRIPTION
Updates the AadSupport PowerShell Module

.PARAMETER All
Will also update AzureAd and Az PowerShell Modules


.EXAMPLE
Update-AadSupport

.NOTES
General notes
#>

function Update-AadSupport
{
    param([switch]$All)

    if($All)
    {
        #Azure AD
        $AadRemoteModule = Find-Module -Name AzureAd
        $AadLocalModule = Get-Module -Name AzureAd -ListAvailable

        if($AadLocalModule)
        {
            if($AadRemoteModule.Version.ToString() -ne $AadLocalModule.Version.ToString())
            {
                Uninstall-Module -Name AzureAd -AllVersions -Verbose
                Install-Module -Name AzureAd -AllowClobber -Verbose
            }
        }

        #Azure AD Preview
        $AadPreviewRemoteModule = Find-Module -Name AzureAdPreview
        $AadPreviewLocalModule = Get-Module -Name AzureAdPreview -ListAvailable

        if($AadPreviewLocalModule)
        {
            if($AadPreviewRemoteModule.Version.ToString() -ne $AadPreviewLocalModule.Version.ToString())
            {
                Uninstall-Module -Name AzureAdPreview -AllVersions -Verbose
                Install-Module -Name AzureAdPreview -AllowClobber -Verbose
            }
        }

        #Az
        $AzRemoteModule = Find-Module -Name Az
        $AzLocalModule = Get-Module -Name Az -ListAvailable

        if($AzLocalModule)
        {
            if($AzRemoteModule.Version.ToString() -ne $AzLocalModule.Version.ToString())
            {
                Uninstall-Module -Name Az -AllVersions -Verbose
                Install-Module -Name Az -AllowClobber -Verbose
            }
        }
        
    }

    $modules = Get-Module -Name AadSupport -ListAvailable

    #Ensure all AadSupport Modules are unloaded
    if($modules)
    {
        Remove-Module -Name AadSupport -Verbose

        #Remove all versions of AadSupport
        Uninstall-Module -Name AadSupport -AllVersions -Verbose
    }

    
    #Remove all versions of AadSupport
    Install-Module -Name AadSupport -AllowClobber

    Write-Host "Update Complete." -ForegroundColor Yellow
}