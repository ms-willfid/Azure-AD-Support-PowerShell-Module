<#
.SYNOPSIS
Quickly create a Self-Signed Certificate to be used for authentication for the Azure AD application.

.DESCRIPTION
Quickly create a Self-Signed Certificate to be used for authentication for the Azure AD application.

This will export a PFX that will contain the Private key.
This will also export the CER that contains the Public Key which can be uploaded to the app in Azure AD.

Once you have uploaded the CER file to Azure AD on the applicatication, you can use the PFX and run the New-AadClientAssertion cmdlet to generate a client assertion.

.PARAMETER CertificatePassword
Either specify Service Principal (SP) Name, SP Display Name, SP Object ID, Application/Client ID, or Application Object ID

.PARAMETER ClientId
Specify the Azure AD application this certificate is meant for.

.PARAMETER CertificateName
When the certificates are exported, you can use this to customize the file name of the certificates.

.PARAMETER AddToApplication
This is a switch. When used, it will add the public key certificate to the Application object in Azure AD.

.EXAMPLE
New-AadApplicationCertificate -ClientId ac4dff1b-b7d7-4453-a4e4-613210c686c9 -CertificatePassword "SomePassword" -AddToApplication

.NOTES

#>
function New-AadApplicationCertificate
{
    [CmdletBinding(DefaultParameterSetName='DefaultSet')]
    Param(
        [Parameter(mandatory=$true)]
        [string]$CertificatePassword,

        [Parameter(mandatory=$true, ParameterSetName = 'ClientIdSet')]
        [string]$ClientId,

        [string]$CertificateName,

        [Parameter(mandatory=$false, ParameterSetName = 'ClientIdSet')]
        [switch]$AddToApplication
    )

    if($ClientId)
    {
        # Get Application object from Azure AD
        $app = Get-AadApplication -id $ClientId
    }
    else { $CliendId = "app" }

    # Create self-signed Cert
    $notAfter = (Get-Date).AddYears(2)

    try
    {
        $cert = (New-SelfSignedCertificate -DnsName "cert://$ClientId" -CertStoreLocation "cert:\LocalMachine\My" -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter)
        
        Write-Verbose "Cert Hash: $($cert.GetCertHash())"
        Write-Verbose "Cert Thumbprint: $($cert.Thumbprint)"
    }

    catch
    {
        Write-Error "ERROR. Probably need to run as Administrator."
        Write-host $_
        return
    }

    if(!$CertificateName)
    {
        $CertificateName = "aad-$ClientId"
    }

    # Export Public portion of Certificate
    $CerPath = "$CertificateName.cer"
    Export-Certificate -Cert $cert -FilePath $CerPath

    # Export PFC with private key
    $PfxPath = "$CertificateName.pfx"
    $SecuredPwd = ConvertTo-SecureString -String $CertificatePassword -Force -AsPlainText
    Export-PfxCertificate -cert $cert -FilePath "$PfxPath" -Password $SecuredPwd 

    Write-Host ""
    Write-Host "Exported Public Key Certificate to..." -ForeGroundColor Yellow
    Write-Host "$CerPath"

    Write-Host ""
    Write-Host "Exported PFX with Private Key to..." -ForeGroundColor Yellow
    Write-Host "$PfxPath"

    if($AddToApplication)
    {
        $AppObjectId = $app.ObjectId
        $KeyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

        Write-Verbose "App Object Id: $AppObjectId"
        Write-Verbose "Key Value: $KeyValue"

        invoke-AadCommand -Command {
            Param($Params)
            New-AzureADApplicationKeyCredential -ObjectId $Params.ObjectId -Type AsymmetricX509Cert -Usage Verify -Value $Params.Value 
        } -Parameters @{
            ObjectId = $AppObjectId
            Value = $KeyValue
        }
        
    }
<<<<<<< HEAD


    function GetX509Certificate($certThumbprint){


        $x509cert = Get-ChildItem "Cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -eq $certThumbprint } | Select-Object -First 1
       
        if(!$x509cert){
       
        $x509cert = Get-ChildItem "Cert:\CurrentUser\My" | Where-Object { $_.Thumbprint -eq $certThumbprint } | Select-Object -First 1
       
        }
       
       
       
       Write-Host "Cert = {$x509cert}"
       
        Return $x509cert
       
       
       
       }
=======
>>>>>>> df812b2feffde2d1fcf1d9bbbe7f62f63115b552
}