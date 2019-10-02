function Get-AadReportCredentialsExpiringSoon
{
    param
    (
        [string]$Days = 45
    )

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $apps = @()

    Write-Host "This might take a while."
    Write-Host "Getting Service Principals..."
    $apps += Get-AzureADServicePrincipal -All $true
    Write-Host "Getting Applications..."
    $apps += Get-AzureADApplication -All $true
    
    $ReturnObject = @()
    foreach($app in $apps)
    {

        foreach($AppCredential in $app.PasswordCredentials)
        {
            $Object = [pscustomobject]@{
                ObjectType = $app.ObjectType
                DisplayName = $app.DisplayName
                ObjectId = $app.ObjectId
                AppId = $app.AppId
                CredentialType = "PasswordCredentials"
                CustomKeyIdentifier = $AppCredential.CustomKeyIdentifier
                EndDate = $AppCredential.EndDate
                StartDate = $AppCredential.StartDate
                KeyId = $AppCredential.KeyId
            }
            $ReturnObject += $Object
        }

        foreach($AppCredential in $app.KeyCredentials)
        {
            $Object = [pscustomobject]@{
                DisplayName = $app.DisplayName
                EndDate = $AppCredential.EndDate
                ObjectType = $app.ObjectType
                CredentialType = "KeyCredentials"
                StartDate = $AppCredential.StartDate
                ObjectId = $app.ObjectId
                KeyId = $AppCredential.KeyId
                CustomKeyIdentifier = $AppCredential.CustomKeyIdentifier
            }
            $ReturnObject += $Object
        }

        
    }

    return $ReturnObject | Sort-Object EndDate | Where-Object {$_.EndDate -lt (Get-Date).AddDays($Days) }
}