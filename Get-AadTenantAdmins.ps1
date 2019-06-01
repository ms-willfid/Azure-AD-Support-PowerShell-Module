<#
.SYNOPSIS
Gets a list of tenant admins.

.DESCRIPTION
Gets a list of tenant admins.

.PARAMETER Role
Provide the role to lookup
By Default 'Company Administrator' is used

.EXAMPLE  
Get-AadTenantAdmins
...See a list of company admins...
.EXAMPLE 
Get-AadTenantAdmins -Role 'Helpdesk Administrator'
...See a list of password or helpdesk admins...
.EXAMPLE 
Get-AadTenantAdmins -Role 8da6f8d3-ef75-42e4-961e-8fba79c29048
...You can also use Role Ids...
.EXAMPLE 
Get-AadTenantAdmins -All
...You can see a list of all Admin Roles...

.NOTES
General notes
#>

function Get-AadTenantAdmins {
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
        [Parameter(Position=0,ParameterSetName="UseRole")]
        $Role = 'Company Administrator',

        [Parameter(ParameterSetName="GetAll")]
        [switch] $All
    )
    
    begin {
        Connect-AadSupport

        try {
            $isGuid = [System.Guid]::Parse($Id)
        } catch {
        }
    }
    
    process {
        
        # Get All Roles
        if($All)
        {
            $_role = Get-AzureADDirectoryRole
        }

        # Look up role based on ObjectID
        elseif($isGuid)
        {
            $_role = Get-AzureADDirectoryRole | Where-Object {$_.ObjectId -eq $role}
        }

        # Look up role based on DisplayName
        else {
            $_role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $role} 
        }


        # Role not found
        if(-not $_role)
        {
            Write-Host "'$Role' role not found." -ForegroundColor Red
            Write-Host "To get a list of valid roles, run..." -ForegroundColor Red
            Write-Host "Get-AzureADDirectoryRole | Sort DisplayName" -ForegroundColor Red
            throw "'$Role' role not found."
        }

        if($_role.Count -gt 1)
        {
            foreach ($role in $_role) {
                $admins = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Select-Object DisplayName, UserPrincipalName, ObjectType | Sort-Object DisplayName
                $count = $admins.Count
                if ($admins.Count -eq $null) {
                    $count = 1
                }
        
                if ($count -gt 0) {
                    Write-Host "========================================"
                    Write-Host "$($role.DisplayName) ($count)" -ForegroundColor Yellow
                    $admins | Format-Table -AutoSize -HideTableHeaders
                }
            }
            return
        }

        else {
            $admins = Get-AzureADDirectoryRoleMember -ObjectId $_role.ObjectId | Select-Object DisplayName, UserPrincipalName 

            # Output list of admins
            Write-Host ""
            Write-Host "Users assigned to the '$Role' role" -ForegroundColor Yellow
            $admins |  Sort-Object DisplayName | format-table
        }
        

        
    }
    
    end {
    }
}