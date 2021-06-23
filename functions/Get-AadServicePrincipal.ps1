<#
.SYNOPSIS
Intelligence to return the service principal object by looking up using any of its identifiers.

.DESCRIPTION
Intelligence to return the service principal object by looking up using any of its identifiers.

.PARAMETER Id
Either specify Service Principal (SP) Name, SP Display Name, SP Object ID, Application/Client ID, or Application Object ID

.EXAMPLE
Get-AadServicePrincipal -Id 'Contoso Web App'

.NOTES
Returns the Service Pricpal object using Get-AzureAdServicePradmin@wiincipal and filter based on the Id parameter
#>

function Get-AadServicePrincipal
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
            ParameterSetName = 'ByServicePrincipalName'
        )]
        $ServicePrincipalName,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByReplyAddress'
        )]
        $ReplyAddress

        
    )

    $Global:ServicePrincipals = @()
    $sp         = $null
    $isGuid     = $null

    # Search By AppId
    if ($AppId) {
        Write-Verbose "Looking for AppId '$AppId'"
        $sp = GetAadSpByAppId $AppId
    }

    # Search By ReplyAddress
    if ($ReplyAddress) {
        Write-Verbose "Looking for '$ReplyAddress'"
        $sp = GetAadSpByReplyAddress $ReplyAddress
    }

    # Search By ServicePrincipalName
    if ($ServicePrincipalName) {
        Write-Verbose "Looking for '$ServicePrincipalName'"
        $sp = GetAadSpByServicePrincipalName -Id $ServicePrincipalName
    }

    # Search By DisplayName
    if ($DisplayName) {
        Write-Verbose "Looking for '$DisplayName'"
        $sp = GetAadSpByDisplayName -Id $DisplayName
    }

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
    }
    
    # Search By All (Any ID)
    if($Id)
    {
        Write-Verbose "Looking for '$Id'"

        # Search for app based on AppId or ObjectId
        if ($isGuid -and -not $sp) {

            # Search for app based on ObjectId
            $sp = $null
            $sp = try { 
                Invoke-AadCommand -Command {
                    Param($Id)
                    Get-AzureADObjectByObjectId -ObjectId $Id 
                } -Parameters $Id
            } catch {}

            if ($sp.ObjectType -eq "ServicePrincipal") {
                Write-Verbose "Service Principal found using ObjectId"
                return $sp
            }

            $appid = $Id
            if ($sp.ObjectType -eq "Application") {
                Write-Verbose "Application found! Looking for Service Principal..."
                $appid = $sp.AppId
                $sp = $null
            }

            # Search for app based on AppId
            $sp = GetAadSpByAppId -Id $appid
            if ($sp) { return $sp }

        } 

        # Search for app based on ServicePrincipalName
        if(-not $sp) {
            $sp = GetAadSpByServicePrincipalName $Id
        }

        # Search for app based on DisplayName
        if(-not $sp) {
            $sp = GetAadSpByDisplayName $Id
        }
    }

    $Global:ServicePrincipals = $null

    # Exit script! Service Principal Not found
    if (-not $sp) {
        throw "$Id Service Principal not found!"
    }

    # Service Principal(s) Found > Only return One result
    if($sp.count -gt 1)
    {
        $sp = $sp | Out-GridView -PassThru -Title "Select Enterprise App"
    }
    return $sp
}


function GetAadSpByAppId
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

    $sp = Invoke-AadCommand -Command {
        Param($AppId)
        Get-AzureADServicePrincipal -filter "AppId eq '$AppId'"
    } -Parameters $Id


    if ($sp) { 
        Write-Verbose "Service Principal found using AppId"
        return $sp
    }

    return
}


function GetAadSpByReplyAddress
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by ReplyUrls"

    $sps = LookupAllServicePrincipals

    $sp = @()
    $sp += $sps | Where-Object {$_.ReplyUrls -contains "$Id"}

    if ($sp) { 
        Write-verbose "Service Principal '$Id' found using Reply Address" 
    }

    return $sp
}



function GetAadSpByServicePrincipalName
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by ServicePrincipalName"

    $sp = Invoke-AadCommand -Command {
        Param($Id)
        Get-AzureADServicePrincipal -filter "servicePrincipalNames/any(x:x eq '$Id')"
    } -Parameters $Id

    # Service Principal Not found yet using ServicePrincipalName (Do wider search)
    if(-not $sp)
    {
        $sps = LookupAllServicePrincipals
        $sp = @()
        $sp += $sps | Where-Object { $_.ServicePrincipalNames -match $Id }
    }

    if ($sp) { 
        Write-verbose "Service Principal(s) '$Id' found using ServicePrincipalName" 
    }

    return $sp
}


function GetAadSpByDisplayName
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    Write-Verbose "Searching by DisplayName"

    $sp = Invoke-AadCommand -Command {
        Param($Id)
        Get-AzureADServicePrincipal -filter "DisplayName eq '$Id'"
    } -Parameters $Id
    
    # Service Principal Not found yet using DisplayName (Do wider search)
    if(-not $sp)
    {
        $sps = LookupAllServicePrincipals
        $sp = @()
        $sp += $sps | Where-Object {$_.DisplayName -match "$Id"}
    }

    if ($sp) { 
        Write-Verbose "Service Principal(s) '$Id' found using DisplayName"
    }

    else
    {
        Write-Verbose "Service Principal(s) '$Id' NOT found using DisplayName"
    }

    return $sp
}


function LookupAllServicePrincipals()
{
    if(-not $Global:ServicePrincipals)
    {
        Write-Verbose "Looking at all Service Principals to find your app. This might take awhile..."
        $Global:ServicePrincipals = Invoke-AadCommand {
            Get-AzureADServicePrincipal -All $true
        }
    }

    return $Global:ServicePrincipals
}