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
$ClientID       = "insert GUID here"             # Should be a ~35 character string insert your info here 
$ClientSecret   = "insert secret here"         # Should be a ~44 character string insert your info here 
$loginURL       = "https://login.windows.net" 
$tenantdomain   = "insert tenant name here"            # For example, contoso.onmicrosoft.com 
 
 
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
        $AuditReport = New-Object PSObject 
        $AuditReportArray = @() 
        foreach ($AuditEntry in $ReportValues) 
            { 
             $AuditReport = New-Object PSObject 
             add-member -inputobject $AuditReport -membertype noteproperty -name "activityDateTime" -value $AuditEntry.activityDateTime 
             add-member -inputobject $AuditReport -membertype noteproperty -name "activityDisplayName" -value $AuditEntry.activityDisplayName 
             add-member -inputobject $AuditReport -membertype noteproperty -name "id" -value $AuditEntry.id 
             add-member -inputobject $AuditReport -membertype noteproperty -name "loggedByService" -value $AuditEntry.loggedByService 
             add-member -inputobject $AuditReport -membertype noteproperty -name "initiatedBy" -value $AuditEntry.user.userPrincipalName 
             if ($AuditEntry.targetResources."displayname".count -lt 2) 
                {add-member -inputobject $AuditReport -membertype noteproperty -name "targetResources" -value $AuditEntry.targetResources."displayname"} 
             else  
                {add-member -inputobject $AuditReport -membertype noteproperty -name "targetResources" -value ([system.String]::Join("; ", $AuditEntry.targetResources."displayname" ))} 
             add-member -inputobject $AuditReport -membertype noteproperty -name "result" -value $AuditEntry.result 
             add-member -inputobject $AuditReport -membertype noteproperty -name "resultReason" -value $AuditEntry.resultReason 
             add-member -inputobject $AuditReport -membertype noteproperty -name "category" -value $AuditEntry.category 
             add-member -inputobject $AuditReport -membertype noteproperty -name "correlationId" -value $AuditEntry.correlationId 
             add-member -inputobject $AuditReport -membertype noteproperty -name "AdditionalDetails" -value ([system.String]::Join("; ", $AuditEntry.additionalDetails )) 
             $AuditReportArray += $AuditReport 
             $AuditReport = $null 
            } 
        $AuditReportArray | select *  |  Export-csv $AuditOutputCSV -NoTypeInformation -Force 
        Write-Host "The report can be found at $AuditOutputCSV". 
        }     
      if ($ConvertedReport.value.count -eq 0) 
        { 
        $AuditOutputCSV = $Pwd.Path + "\" + $tenantname + "_$reportname.txt" 
        Get-Date |  Out-File -FilePath $AuditOutputCSV  
        "No Data Returned. This typically means either the tenant does not have Azure AD Premium licensing or that the report query succeeded however there were no entries in the report. " |  Out-File -FilePath $AuditOutputCSV -Append 
        } 
    } 
 
 
 
$7daysago = "{0:s}" -f (get-date).AddDays(-7) + "Z" 
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
$URIfilter = "?`$filter=activityDateTime gt $PastPeriod"  
$url = "https://graph.microsoft.com/v1.0/auditLogs/signIns" + $URIfilter 
GetReport $url "DirectoryAudits" $tenantdomain 