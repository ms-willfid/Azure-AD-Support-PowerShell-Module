PARAM ($PastDays = 30, $PastHours ) 
#************************************************ 
# PullAzureADAuditReport.ps1 
# Version 1.1 
# Date: 10-29-2018 
# Author: Tim Springston [MSFT] 
# Description: This script will search an Azure AD tenant which has Azure AD Premium licensing and AAD Auditing enabled  
#  using GraphApi for audit results for a specified period till current time. At least one 
#  user must be assigned an AAD Premium license for this to work. 
# Results are placed into a CSV file for review. 
#************************************************ 
cls 
# This script will require the Web Application and permissions setup in Azure Active Directory 
$ClientID       = "6dee6448-1ceb-477a-ac64-f9b6fdb67a21"             # Should be a ~35 character string insert your info here 
$ClientSecret   = "l7YzZN69QAkfT0rnmkhzhjCIhfCM_/.]"         # Should be a ~44 character string insert your info here 
$loginURL       = "https://login.microsoftonline.com" 
$tenantdomain   = "williamfiddes.onmicrosoft.com"            # For example, contoso.onmicrosoft.com 
 
 
Write-Host "Collecting Azure AD audit log entries for tenant $tenantname`." 
 
function GetReport      ($url, $reportname, $tenantname) 
{ 
    # Get an Oauth 2 access token based on client id, secret and tenant domain 
    $loginURL       = "https://login.windows.net" 
    $resource = "https://graph.microsoft.com" 
    $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.csv" 
    $body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret} 
    $oauth      = Invoke-RestMethod -Method POST -Uri $loginURL/$tenantname/oauth2/token?api-version=1.0 -Body $body 
    if ($oauth.access_token -ne $null) 
    { 
        $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"} 
        $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url -Method GET) 
        $ConvertedReport = ConvertFrom-Json -InputObject $myReport.Content  
        $ReportValues = $ConvertedReport.value  
        $nextURL = $ConvertedReport."@odata.nextLink" 
    if ($nextURL -ne $null) 
    { 
        Do  
        { 
            $NextResults = Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $nextURL -Method Get -ErrorAction SilentlyContinue  
            $NextConvertedReport = ConvertFrom-Json -InputObject $NextResults.Content  
            $ReportValues += $NextConvertedReport.value 
            $nextURL = $NextConvertedReport."@odata.nextLink" 
        } While ($nextURL -ne $null) 
    } 

    #Place results into a CSV 
    $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.csv" 
    #Create a PSObject to place the results into before export to CSV so that values are expanded 
    $AuditReportArray = @() 
    foreach ($AuditEntry in $ReportValues) 
    { 
            $AuditReportArray += $AuditEntry
        } 
         
    }

    $AuditReportArray | select *  |  Export-csv $AuditOutputCSV -NoTypeInformation -Force 
        Write-Host "The report can be found at $AuditOutputCSV".

    if ($ConvertedReport.value.count -eq 0) 
    { 
        $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.txt" 
        Get-Date |  Out-File -FilePath $AuditOutputCSV  
        "No Data Returned. This typically means either the tenant does not have Azure AD Premium licensing or that the report query succeeded however there were no entries in the report. " |  Out-File -FilePath $AuditOutputCSV -Append 
    } 
} 
 
if ($PastHours -gt 0) 
{ 
    $Date = Get-Date 
    $PastPeriod = "{0:s}" -f (Get-Date).AddHours(-($PastHours)) + "Z" 
    $TimePeriodStatement = " past $PastHours hours. Current time is $Date`." 
} 
else 
{ 
    $DateRaw = Get-Date 
    $Date = ($DateRaw.Month.ToString()) + '-' + ($DateRaw.Day.ToString()) + "-" + ($DateRaw.Year.ToString()) 
    $PastPeriod =  "{0:s}" -f (get-date).AddDays(-($PastDays)) + "Z" 
    $TimePeriodStatement = "past $PastDays days prior to $Date`." 
} 
         
Write-Output "Searching the tenant $Tenantname for AAD audit events for the $TimePeriodStatement" 
$URIfilter = "?`$filter=createdDateTime gt $PastPeriod"  
$url = "https://graph.microsoft.com/v1.0/auditLogs/signIns" + $URIfilter 
GetReport $url "DirectorySignIns" $tenantdomain 