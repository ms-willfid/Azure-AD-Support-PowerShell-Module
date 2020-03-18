function SerializeToJson
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Input
    )    

    
    [System.IO.MemoryStream] $stream = [System.IO.MemoryStream]::new()

    $ser = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($Input.GetType())
    $ser.WriteObject($stream, $Input);
    $ReturnString = [Encoding.UTF8]::GetString($stream.ToArray(), 0, $stream.Position);

    $stream.Dispose()

    return $ReturnString
}