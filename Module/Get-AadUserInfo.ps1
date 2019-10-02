function Get-AadUserInfo
{
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Token
    )

    $response = Invoke-AadProtectedApi -Endpoint "https://login.microsoftonline.com/common/openid/userinfo" -Bearer $Token

    return $response
}