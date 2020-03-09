<#
.SYNOPSIS
Intelligence to return the Application object by looking up using any of its identifiers.

.DESCRIPTION
Intelligence to return the Application object by looking up using any of its identifiers.

.PARAMETER Id
Either specify Application Name, Display Name, Object ID, Application/Client ID, or Application Object ID

.EXAMPLE
Get-AadApplication -Id 'Contoso Web App'

.NOTES
Returns the Application object using Get-AzureAdApplication and filter based on the Id parameter
#>

Set-Alias -Name Get-AadApp -Value Get-AadApplication

function Get-AadApplication
{
    [CmdletBinding(DefaultParameterSetName='ByAnyId')]
    param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true,
            ParameterSetName = 'ByAnyId'
        
        )]
        $Id,


        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByAppId'
        )]
        $AppId,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByDisplayName'
        )]
        $DisplayName,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByAppUriId'
        )]
        $AppUriId,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByReplyAddress'
        )]
        $ReplyAddress

        
    )
    

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $Global:Applications = @()
    $app         = $null
    $isGuid     = $null

    # Search By AppId
    if ($AppId) {
        Write-Verbose "Looking for '$AppId'"
        $app = GetAadAppByAppId $AppId
    }

    # Search By ReplyAddress
    if ($ReplyAddress) {
        Write-Verbose "Looking for '$ReplyAddress'"
        $app = GetAadAppByReplyAddress $ReplyAddress
    }

    # Search By AppUriId
    if ($AppUriId) {
        Write-Verbose "Looking for '$AppUriId'"
        $app = GetAadAppByAppUriId $AppUriId
    }

    # Search By DisplayName
    if ($DisplayName) {
        Write-Verbose "Looking for '$DisplayName'"
        $sp = GetAadAppyDisplayName -Id $DisplayName
    }

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
    }
    
    # Search By All (Any ID)
    if($Id)
    {
        # Search for app based on AppId or ObjectId
        if ($isGuid -and -not $app) {

            # Search for app based on ObjectId
            $app = $null
            $app = try { 
                Invoke-AadCommand -Command {
                    Param($Id)
                    Get-AzureADObjectByObjectId -ObjectId $Id 
                } -Parameters $Id
            } catch {}

            if ($app.ObjectType -eq "Application") {
                Write-Verbose "Application found using ObjectId"
            }

            $appid = $Id
            if ($app.ObjectType -eq "ServicePrincipal") {
                Write-Verbose "Service Principal found! Looking for Application..."
                $appid = $app.AppId
                $app = $null
            }

            # Search for app based on AppId
            if(-not $app)
            {
                $app = GetAadAppByAppId -Id $appid
                if ($app) { return $app }
            }
        } 
        # Search for app based on AppUriId or DisplayName
        if(-not $app) {
            $app = @()
            $app += GetAadAppByDisplayName $Id
            $app += GetAadAppByAppUriId $Id
        }
    }

    $Global:Applications = $null

    # Exit script! Application Not found
    if (-not $app) {
        throw "Azure AD Application '$Id' not found!"
    }

    # Application(s) Found > Only return One result
    if($app.count -gt 1)
    {
        $app = $app | Out-GridView -PassThru -Title "Select Application"
    }
    return $app
}


function GetAadAppByAppId
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by AppId"

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
        throw "Invalid App Id"
    }

    $app = Invoke-AadCommand {
        Param($Id)
        Get-AzureAdApplication -filter "AppId eq '$Id'"
    } -Parameters $Id

    if ($app) { 
        Write-Verbose "Application found using AppId"
        return $app
    }

    return
}


function GetAadAppByReplyAddress
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by ReplyUrls"

    $apps = LookupAllApplications

    $app = @()
    $app += $apps | Where-Object {$_.ReplyUrls -contains "$Id"}

    if ($app) { 
        Write-verbose "Application '$Id' found using Reply Address" 
    }

    return $app
}



function GetAadAppByAppUriId
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by AppUriId"

    $apps = LookupAllApplications

    $app = @()
    $app += $apps | Where-Object { $_.IdentifierUris -match $Id }

    if ($app) { 
        Write-verbose "Application(s) '$Id' found using AppUriId" 
    }

    return $app
}


function GetAadAppByDisplayName
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by DisplayName"

    $app = Invoke-AadCommand {
        Param($Id)
        Get-AzureADApplication -filter "DisplayName eq '$Id'"
    } -Parameters $Id
    
    # Application Not found yet using DisplayName (Do wider search)
    if(-not $app)
    {
        $apps = LookupAllApplications
        $app = @()
        $app += $apps | Where-Object {$_.DisplayName -match "$Id"}
    }

    if ($app) { 
        Write-Verbose "Application(s) '$Id' found using DisplayName"
    }

    return $app
}


function LookupAllApplications()
{
    if(-not $Global:Applications)
    {
        Write-Host "Looking at all Applications to find your app. This might take awhile..."
        $Global:Applications = Invoke-AadCommand {
            Get-AzureADApplication -All $true
        }
    }

    return $Global:Applications
}