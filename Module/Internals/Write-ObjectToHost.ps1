function Write-ObjectToHost
{
    [cmdletbinding()]
    param(
        # PowerShell Object to write all Properties to Host
        [Parameter(Mandatory=$True,Position=0,ValueFromPipeline = $true)]
        [psobject]
        $InputObject,
        $Depth=0    
    )

    $Type = $InputObject.GetType().Name
    
    if($Type -eq "Hashtable" -or $Type -eq "OrderedDictionary")
    {
        $InputObject = New-Object -TypeName PSObject -Property $InputObject
    }

    $Indent = ""
    for($i=0; $i -lt $Depth; $i++)
    {
        $Indent = $Indent + "    "
    }

    foreach($object in $InputObject)
    {

    

        $Members = $object | Get-Member

        ForEach($Member in $Members)
        {
            if($Member.MemberType -eq "NoteProperty" -or $Member.MemberType -eq "Property")
            {
                Write-Host "$Indent $($Member.Name) : "  -NoNewline  -ForegroundColor Yellow

                if($InputObject.($Member.Name) -match "Collections")
                {
                    $Depth++
                    Write-Host ""
                    Write-ObjectToHost $Object.($Member.Name) -Depth $Depth
                    
                }
                else {
                    Write-Host $Object.($Member.Name)
                }
            }
            
        }

        Write-Host ""

    }
}

<# TEST
$Object = @{
    Name = "Stuff Name"
    Prop1 = "Property 1"
    Prop2 = @{
        Prop2Name = "Prop 2 Name"
        Prop2Desc = "Desc stuff"
        Prop2Collection = @{
            Prop2C_Name = "Prop 2 Collection Name"
        }
    }
    Prop3 = @("Item1","Item2")
}

Write-ObjectToHost $Object
#>