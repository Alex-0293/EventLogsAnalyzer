Param (
    [datetime] $Start,
    [datetime] $End,
    [string]   $OutputXMLPath
)

Write-host "Start: $Start end: $End"
Write-Host "Output file: $OutputXMLPath"
Write-Host ""

$Logs  =  Get-WinEvent -ListLog *

$Res = @()        
Foreach($Log in $Logs) {           
    $Log.LogName
    $Filter = @{
        LogName            = $Log.LogName
        StartTime          = $Start
        EndTime            = $End
    }
    $Res += Get-WinEvent -FilterHashTable $Filter -ErrorAction SilentlyContinue
}  
if($Res){
        $Res | Export-Clixml -path $OutputXMLPath -Encoding utf8 -Force 
}   