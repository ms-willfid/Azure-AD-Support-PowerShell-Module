function Log-AadSupportRunspace
{
    Param(
        [Parameter(
            mandatory=$true,
            Position=0,
            ValueFromPipeline = $true
        )]
        [AllowNull()]
        $Message,
        [switch]$Force=$false
    )

    if(-not $Message)
    {
        return
    }

    $ScriptPath = $GlobalParams.Path
    . "$ScriptPath\internals\imports\LoggingFunction.ps1"

    if($Message)
    {
        if($Force)
        {
            
            Log-AadSupportMessage -Message $Message -Force
        }
        else {
            
            Log-AadSupportMessage -Message $Message
        }
    }

}