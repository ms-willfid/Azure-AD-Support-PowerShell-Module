function Export-AadAzureRoleAssignments {

    # REQUIRE AadSupport Session
    RequireConnectAadSupport
    # END REGION

    $RoleAssignments = @()

    #Traverse through each Azure subscription user has access to
    $subscriptions = Get-AzSubscription -TenantId $Global:AadSupport.Session.TenantId

    Foreach ($sub in $subscriptions) {
        $SubName = $sub.Name
        if ($sub.Name -ne "Access to Azure Active Directory") { # You can't assign roles in Access to Azure Active Directory subscriptions
            
            Write-Host "Analyzing Subscription '$($sub.Name) (Id:$($sub.id))'  "
            Set-AzContext -SubscriptionId $sub.id | Out-Null

            Try {
                $SubRoleAssignments = Get-AzRoleAssignment -IncludeClassicAdministrators
                $RoleAssignments += $SubRoleAssignments
            } 
            Catch {
                Write-Output "Failed to collect RBAC permissions for $subname"
            }
            
            #Custom Roles do not display their Name in these results. We are forcing this behavior for improved reporting
            Foreach ($role in $RoleAssignments) {
              $ObjectId = $role.ObjectId
              $DisplayName = $role.DisplayName
              If (-not $role.RoleDefinitionName) {
                $role.RoleDefinitionName = (Get-AzRoleDefinition -Id $role.RoleDefinitionId).Name
              }
              if ($role.ObjectType -eq "Group" -and !(Test-Path -path "GroupMembers--$DisplayName.csv")) {
                $Members = Get-AzureADGroupMember -ObjectId $ObjectId
                
                $Path = Get-Location
                $FilePath = "$Path\GroupMembers--$DisplayName.csv"

                $Members | Export-CSV $FilePath -NoTypeInformation -Force
                Write-Host "Exported Group Memberships"
                Write-Host " > $FilePath"
              }
            }
            #Export the Role Assignments to a CSV file labeled by the subscription name

            $Path = Get-Location
            $FilePath = "$Path\Subscription--$SubName-Roles.csv"

            $SubRoleAssignments | Export-CSV $FilePath -NoTypeInformation -Force
            Write-Host "Exported Subscription Role Assignments"
            Write-Host " > $FilePath"
        }

        else {
          Write-Host "Skipping 'Access to Azure Active Directory'. This is not going to have Role Assignments."
        }
    }

    #Export All Role Assignments in to a single CSV file
    $Path = Get-Location
    $FilePath = "$Path\Subscription--All-Roles.csv"

    $RoleAssignments | Export-CSV ".\Subscription--All-Roles.csv" -NoTypeInformation -Force

    Write-Host "Exported All Role Assignments"
    Write-Host " > $FilePath"

    # HTML report
    $a = "<style>"
    $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;font-family:arial}"
    $a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}"
    $a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}"
    $a = $a + "</style>"

    $Path = Get-Location
    $FilePath = "$Path\Subscription--All-Roles.html"

    $RoleAssignments | ConvertTo-Html -Head $a| Out-file $FilePath -Force
    Write-Host "Exported HTML"
    Write-Host " > $FilePath"
}