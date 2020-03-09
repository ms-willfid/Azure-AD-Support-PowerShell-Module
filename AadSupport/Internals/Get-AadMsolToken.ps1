function Get-AadMsolToken
{

}

function New-AadMsolRequest
{
$StringBuilder = @'
<s:Envelope
    xmlns:s="http://www.w3.org/2003/05/soap-envelope\"
    xmlns:a="http://www.w3.org/2005/08/addressing">
    <s:Header>
        <a:Action s:mustUnderstand="1">http://provisioning.microsoftonline.com/IProvisioningWebService/ListUsers</a:Action>
        <a:MessageID>urn:uuid:fcca58a1-1a42-47ae-89e0-2146d0ab7f75</a:MessageID>
        <a:ReplyTo>
            <a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>
        </a:ReplyTo>
        <UserIdentityHeader
            xmlns="http://provisioning.microsoftonline.com/"
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <BearerToken
                xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService">Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkN0ZlFDOExlLThOc0M3b0MyelFrWnBjcmZPYyIsImtpZCI6IkN0ZlFDOExlLThOc0M3b0MyelFrWnBjcmZPYyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLndpbmRvd3MubmV0IiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYWEwMGQxZmEtNTI2OS00ZTFjLWIwNmQtMzA4NjgzNzFkMmM1LyIsImlhdCI6MTU2MTQ5MTI1MiwibmJmIjoxNTYxNDkxMjUyLCJleHAiOjE1NjE0OTI3NTIsImFjciI6IjEiLCJhaW8iOiJBU1FBMi84TEFBQUFydVczcElqRUVQRW0rdXhXM2RFNENLRi92OTdqOEQrWVJHNTNPam40aHdVPSIsImFtciI6WyJwd2QiXSwiYXBwaWQiOiIxYjczMDk1NC0xNjg1LTRiNzQtOWJmZC1kYWMyMjRhN2I4OTQiLCJhcHBpZGFjciI6IjAiLCJkZXZpY2VpZCI6ImEyMjY1Yzc2LTg3ODYtNGVmMi05MTFjLWQzYTAyZTVjYzJkYyIsImZhbWlseV9uYW1lIjoiQWNjb3VudCIsImdpdmVuX25hbWUiOiJBZG1pbmlzdHJhdG9yIiwiaXBhZGRyIjoiNDcuMTg0LjE2LjE4MiIsIm5hbWUiOiJBZG1pbiBBY2NvdW50Iiwib2lkIjoiNDNhNTQ4OGMtOWRlNi00MmU1LWFiZGUtM2NiMzRlOGYwZWRjIiwicHVpZCI6IjEwMDM3RkZFODRDOEU2MjQiLCJzY3AiOiJ1c2VyX2ltcGVyc29uYXRpb24iLCJzdWIiOiI0VE5NRGtmVGFXOGYwUEx2ekJwd1ZUdldOb21ldTBGaWYtOU5reHl4VjkwIiwidGVuYW50X3JlZ2lvbl9zY29wZSI6Ik5BIiwidGlkIjoiYWEwMGQxZmEtNTI2OS00ZTFjLWIwNmQtMzA4NjgzNzFkMmM1IiwidW5pcXVlX25hbWUiOiJhZG1pbkB3aWxsaWFtZmlkZGVzLm9ubWljcm9zb2Z0LmNvbSIsInVwbiI6ImFkbWluQHdpbGxpYW1maWRkZXMub25taWNyb3NvZnQuY29tIiwidXRpIjoiM1ZoLWktNEc4RTZUVEhFQVlLb3ZBQSIsInZlciI6IjEuMCJ9.U5JkWSURBMWdlhVtof0-mXzNlTE8q8ZHL4P6Ea5lIrHw4ZcfEevCB8CYzxr9rUjYesle5B1O_CGmmItYvxARc3SKfVpIAb1BRXIE-v1Qthe8stLcVOhBYfhV55he9XalpBexLkOxnjHiheWqTWMfkVh0h-amgUoFAY3YwMqjv3g7VhEdzsWUmKHG1k5-uzYS85IB6vOvt_7rrHAmHEJHX2892xFLoSPdRmgDqdtl3twKYU_so7gpSBnuYNyvusfPin7G7QUlY_gJH0HW0JC6TvWO4slp3HbZtJKzqmNSdP_p1SSV8yXw2jGg3CHydNYwGuwjMJFAt-mGlOv5yc_aoQ
            </BearerToken>
            <LiveToken i:nil="true"
                xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService"/>
            </UserIdentityHeader>
            <BecContext
                xmlns="http://becwebservice.microsoftonline.com/"
                xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                <DataBlob
                    xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService">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
                </DataBlob>
            </BecContext>
            <ClientVersionHeader
                xmlns="http://provisioning.microsoftonline.com/"
                xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                <ClientId
                    xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService">50afce61-c917-435b-8c6d-60aa5a8b8aa7
                </ClientId>
                <Version
                    xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService">1.2.166.0
                </Version>
            </ClientVersionHeader>
            <ContractVersionHeader
                xmlns="http://becwebservice.microsoftonline.com/"
                xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                <BecVersion
                    xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService">Version38
                </BecVersion>
            </ContractVersionHeader>
            <TrackingHeader
                xmlns="http://becwebservice.microsoftonline.com/">5dd66048-e66d-4fc2-b6e6-c6713014235c
            </TrackingHeader>
            <a:To s:mustUnderstand="1">https://provisioningapi.microsoftonline.com/provisioningwebservice.svc</a:To>
        </s:Header>
        <s:Body>
            <ListUsers
                xmlns="http://provisioning.microsoftonline.com/">
                <request
                    xmlns:b="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration.WebService"
                    xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                    <b:BecVersion>Version16</b:BecVersion>
                    <b:TenantId i:nil="true"/>
                    <b:VerifiedDomain i:nil="true"/>
                    <b:UserSearchDefinition
                        xmlns:c="http://schemas.datacontract.org/2004/07/Microsoft.Online.Administration">
                        <c:PageSize>500</c:PageSize>
                        <c:SearchString i:nil="true"/>
                        <c:SortDirection>Ascending</c:SortDirection>
                        <c:SortField>None</c:SortField>
                        <c:AccountSku i:nil="true"/>
                        <c:BlackberryUsersOnly i:nil="true"/>
                        <c:City i:nil="true"/>
                        <c:Country i:nil="true"/>
                        <c:Department i:nil="true"/>
                        <c:DomainName i:nil="true"/>
                        <c:EnabledFilter i:nil="true"/>
                        <c:HasErrorsOnly i:nil="true"/>
                        <c:IncludedProperties i:nil="true"
                            xmlns:d="http://schemas.microsoft.com/2003/10/Serialization/Arrays"/>
                            <c:IndirectLicenseFilter i:nil="true"/>
                            <c:LicenseReconciliationNeededOnly i:nil="true"/>
                            <c:ReturnDeletedUsers i:nil="true"/>
                            <c:State i:nil="true"/>
                            <c:Synchronized i:nil="true"/>
                            <c:Title i:nil="true"/>
                            <c:UnlicensedUsersOnly i:nil="true"/>
                            <c:UsageLocation i:nil="true"/>
                        </b:UserSearchDefinition>
                    </request>
                </ListUsers>
            </s:Body>
        </s:Envelope>
'@
}