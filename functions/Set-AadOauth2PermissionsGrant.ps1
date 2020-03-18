

function Set-AadOauth2PermissionsGrant
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Id,

        [Parameter(Mandatory=$true)]
        [string]$Scope,

        [ValidateSet('SET','ADD','REMOVE')]
        $Method = "SET"
    )

    $Scopes = $Scope.Split(" ").Split(";").Split(",")

    $GraphApiUrl = "https://graph.microsoft.com/beta/oauth2PermissionGrants/$Id"

    # GET ACCESS TOKEN FOR AAD GRAPH
    $AccessToken = GetTokenForMsGraph

    if(!AccessToken)
    {
        throw "Unable to acquire token."
    }

    

    $Grant = @{}

    if($Method -eq "SET")
    {
        $Grant.scope = $Scope
    }

    else{
        # ------------------------------------------------
        # GET OAUTH2PERMISSIONGRANT

        $Grant =  Invoke-AadProtectedApi `
        -Client $Global:AadSupport.Clients.AzureAdPowershell.ClientId `
        -Resource $MsGraphEndpoint `
        -Endpoint $GraphApiUrl -Method "GET"
    
        if(!Grant)
        {
            throw "OAuth2PermissionGrant not found!"
        }
        
        if($Method -eq "ADD")
        {
            foreach($item in $Scopes)
            {
                if($item.Replace(" ","")) {
                    if(!$item -match $Grant.scope)
                    {
                        $Grant.scope += $item
                    }
                }
            }
        }

        if($Method -eq "REMOVE")
        {
            
        }
    }

    $Body = @{
        scope = $Grant.scope
    } | ConvertTo-Json -Compress

    # ------------------------------------------------
    #Create the admin permission grant via graph api
    Invoke-WebRequest -Uri $MsGraphEndpoint -Headers @{ "Authorization" = "Bearer " + $AccessToken } -Method Patch -Body $Body -ContentType "application/json"

}