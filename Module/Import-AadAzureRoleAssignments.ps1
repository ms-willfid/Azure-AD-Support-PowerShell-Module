<#
.SYNOPSIS
Import Azure RBAC Role Assignments from a CSV exported using Export-AadAzureRoleAssignments

.DESCRIPTION
Import Azure RBAC Role Assignments from a CSV exported using Export-AadAzureRoleAssignments

.PARAMETER ImportCsv
Parameter description

.PARAMETER SubId
Parameter description

.EXAMPLE
Import-AadAzureRoleAssignments -SubId 'efb4bb0c-e454-4530-8753-753f22c8f901' -ImportCsv '.\Subscription--Pay-As-You-Go-Roles.csv'

.NOTES
General notes
#>

function Import-AadAzureRoleAssignments {
# Ensure you are signed in to Az Account (Connect-AzAccount)
# Ensure you are signed in to AzureAD (Connect-AzureAD)

# $ImportCSV : Location of CSV file for role assignments
# $SubId : Azure subscription ID to re-apply permissions to
  param (
    [Parameter(Mandatory=$true)]
    [string]$ImportCsv, 
    [Parameter(Mandatory=$true)]
    [string]$SubId
  )

  # REQUIRE AadSupport Session
  if($Global:AadSupportModule)
  {
    RequireConnectAadSupport
  }
  # END REGION
  
  $InitialDomain = (Get-AzureADDomain | where {$_.IsInitial -eq $true}).Name

  $HaveAccess = 0
  try {
    
    Set-AzContext -Subscription $SubId -Tenant $Global:AadSupport.Session.TenantId | Out-Null
    $HaveAccess = $True
  } Catch {
    $HaveAccess = $False
    Write-Host "$SubId does not exist or You don't have access to it" -ForegroundColor Red
  }

  If ($HaveAccess) {
      $roles = Import-CSV $ImportCsv
  
      if(-not $roles)
      {
        return
      }

      # Start assigning roles
      foreach ($role in $roles) {
        
        $RoleDefinitionName = $role.RoleDefinitionName
        $RoleDisplayName = $role.DisplayName
        $RoleObjectId = $role.ObjectId
        $RoleScope = $role.scope
        $RoleSignInName = $role.SignInName
        $RoleDefId = $role.RoleDefinitionId

        if($RoleDisplayName)
        {
          Write-Host "Assigning role for '$RoleDisplayName' to '$RoleDefinitionName' @ '$RoleScope'"
        }
        else 
        {
          Write-Host "Assigning role for '$RoleObjectId' to '$RoleDefinitionName' @ '$RoleScope'"
        }
        

        if($RoleDefinitionName -match "ServiceAdministrator" -or $RoleDefinitionName -match "AccountAdministrator")
        {
          Write-Host " -- Skipping assignment for '$RoleDisplayName' to '$RoleDefinitionName'. Not possible with this script."
          Continue
        }

        if ($role.Scope -ne "/") { # Skip Azure AD scope assignments as it is not possible to assign to this scope
      
          # Unknown Role Assignments
          if($role.ObjectType -eq "Unknown")
          {
            Write-Host " -- This is a Unknown Role Assignment. Most likely the Azure AD Object assigned to this was deleted."
            Continue
          }

          # Group Role Assignment
          elseif ($role.ObjectType -eq "Group") {

            $group = Get-AzureAdGroup -Filter "DisplayName eq '$($role.DisplayName)'"

            if ($group.count -eq 1) {
              $GroupId = $group.id
              try{
                
                $assignment = $null
                $assignment = Get-AzRoleAssignment -scope $rolescope -ObjectId $GroupId -RoleDefinitionId $RoleDefId
                if(-not $assignment)
                {
                  New-AzRoleAssignment -scope $rolescope -ObjectId $GroupId -RoleDefinitionId $RoleDefId
                }
              }
              catch{
                Write-Host " -- The role assignment already exists." -ForegroundColor Yellow
              }
              
            } 
            elseif ($group.count -gt 1) { 
              write-Host " -- Could not assign Access Control to Group $roleDisplayName" -ForegroundColor Yellow
              write-Host " -- Multiple groups exist with the same DisplayName; unable to identify which group to assign Access Control" -ForegroundColor Yellow
            } 
            else { 
              write-Host " -- Could not assign Access Control to Group '$roleDisplayName'" -ForegroundColor Yellow
              write-Host " -- No groups exist with that name" -ForegroundColor Yellow
            }

            Continue
          } 

          # User Role Assignment
          elseif ($role.ObjectType -eq "User") {
            $isExternal = $false # User is external and SignInName has underscore to be replaced by @
        
            #Modify SignInName if external user
            $i = $role.SignInName.indexOf("#EXT#")
            if ($i -eq -1) { $i = $role.SignInName.length }
            else {
              $isExternal = $true
            }
            $role.SignInName = $role.SignInName.Substring(0,$i)

            if ($isExternal -eq $true) {
              $ati = $role.SignInName.lastindexOf("_")
              $part1 = $role.SignInName.Substring(0,$ati)
              $part2 = $role.SignInName.Substring(($ati+1))
              $role.SignInName = $part1 + "@" + $part2
            }

            # Look for UPN suffix
            $ati = $role.SignInName.indexOf("@")
            $suffix = $role.SignInName.Substring(($ati+1))

            # Check if user domain is verified, If not then this user is still external user
            $DomainExists = (Get-AzureAdDomain | where {$suffix -match $_.Name}).Count
            if (!$DomainExists) {
                $role.SignInName = $role.SignInName.Replace("@","_")
                $role.SignInName = $role.SignInName + "#EXT#@" + $InitialDomain
            }

            $SignInName = $role.SignInName
            $user = Get-AzureADUser -ObjectId $role.SignInName
            $UserObjectId = $user.ObjectId

            if ($RoleDefinitionName -eq "CoAdministrator") {
              $rolescope = "/subscriptions/$subid"
              $RoleDefId = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
            }

            if ($user.count -eq 1) {
              try {
                $assignment = $null
                $assignment = Get-AzRoleAssignment -Scope $RoleScope -ObjectId $UserObjectId -RoleDefinitionId $RoleDefId
                if(-not $assignment)
                {
                  New-AzRoleAssignment -scope $rolescope -ObjectId $userObjectId -RoleDefinitionId $RoleDefId
                }
                else {
                  Write-Host " -- Role Assignment already exists."
                }
                
              }
              catch
              {

              }
              
            } elseif ($user.count -eq 0) {
              write-Host " -- Could not assign Access Control to User $roleSignInName" -ForegroundColor Yellow
              write-Host " -- User does not exist or can not be found!"  -ForegroundColor Yellow
            }

            Continue
          } 

          # Service Principal Role Assignment
          elseif ($role.ObjectType -match "ServicePrincipal") 
        
          {
            $sp = Get-AzureAdServicePrincipal -Filter "DisplayName eq '$RoleDisplayName'"
            if($sp)
            {
              $assignment = $null
              $assignment = Get-AzRoleAssignment -scope $RoleScope -ObjectId $sp.ObjectId -RoleDefinitionId $RoleDefId
              
              if(-not $assignment)
              {
                New-AzRoleAssignment -scope $RoleScope -ObjectId $sp.ObjectId -RoleDefinitionId $RoleDefId
              }
              else
              {
                Write-Host " -- Role Assignment already exists."
              }
              
            } 

            else 
            {
                write-host " -- Did not find Service Principal: $RoleDisplayName" -ForegroundColor Yellow
            }

            Continue
          } 
        } 
        
        else 
        { write-host "Assigning to scope '/' level not allowed" -ForegroundColor Yellow}

      }
  }
}