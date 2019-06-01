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

Set-Alias -Name Get-AadSp -Value Get-AadServicePrincipal

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
            ParameterSetName = 'ByName'
        )]
        $Name,

        [Parameter(
            mandatory=$true,
            ParameterSetName = 'ByAppId'
        )]
        $AppId
    )

    Begin {
        # REQUIRE AadSupport
        if($global:AadSupportModule) 
        { Connect-AadSupport }
        # END REGION

        $Global:ServicePrincipals = @()
        $sp         = $null
        $isGuid     = $null
    }

    Process {

        if ($AppId) {
            $sp = GetAadSpByAppId $AppId
            return ($sp | Format-Table)
        }

        if ($Name) {
            $sp = GetAadSpByName $Name
            return $sp
        }

        try {
            $isGuid = [System.Guid]::Parse($Id)
        } catch {
        }

        # Search for app based on AppId or ObjectId
        if ($isGuid) {

            # Search for app based on ObjectId
            $sp = $null
            $sp = try { Get-AzureADObjectByObjectId -ObjectId $Id } catch {}

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
        

        # Search for app based on ServicePrincipalName or DisplayName
        if(-not $sp) {
            $sp = GetAadSpByName $Id
            if ($sp) { return $sp }
        }

        
    }

    End {
        $Global:ServicePrincipals = $null

        # Exit script! Service Principal Not found
        if (-not $sp) {
            throw "Azure AD Service Principal '$Id' not found!"
        }
    }

}


function GetAadSpByName
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    $sp = Get-AzureADServicePrincipal -filter "servicePrincipalNames/any(x:x eq '$Id')"
    if ($sp) { 
        Write-Verbose "Service Principal '$Id' found using ServicePrincipalName" 
        return $sp
    }

    $sp = Get-AzureADServicePrincipal -filter "DisplayName eq '$Id'"
    if ($sp) { 
        Write-Verbose "Service Principal '$Id' found using DisplayName" 
        return $sp
    }

    Write-Host "Looking at all Service Principals to find your app. This might take awhile..."
    $Global:ServicePrincipals = Get-AzureADServicePrincipal -All $true

    $sp = @()
    $sp += $Global:ServicePrincipals | Where-Object {$_.DisplayName -match "$Id"}
    $sp += $Global:ServicePrincipals | Where-Object {$_.ServicePrincipalNames -match "$Id"}

    if ($sp) { 
        Write-verbose "Service Principal '$Id' found using wide search" 
        return $sp
    }

    return
}

function GetAadSpByAppId
{
    param(
        [Parameter(
            mandatory=$true,
            ValueFromPipeline = $true)]
        $Id
    )

    try {
        $isGuid = [System.Guid]::Parse($Id)
    } catch {
        throw "Invalid App Id"
    }

    $sp = Get-AzureADServicePrincipal -filter "AppId eq '$Id'"
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

    $sp = Get-AzureADServicePrincipal -filter "ReplyUrls/any(x:x eq '$Id')"
    if ($sp) { 
        Write-Verbose "Service Principal '$Id' found using ServicePrincipalName" 
        return $sp
    }

    
    $sps = Get-AzureADServicePrincipal -All $true

    $sp = @()
    $sp += $sps | Where-Object {$_.DisplayName -match "$Id"}
    $sp += $sps | Where-Object {$_.ServicePrincipalNames -match "$Id"}

    if ($sp) { 
        Write-verbose "Service Principal '$Id' found using wide search" 
        return $sp
    }

    return
}
