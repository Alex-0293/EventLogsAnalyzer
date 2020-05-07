<#
    .SYNOPSIS 
        .AUTHOR
        .DATE
        .VER
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
Param (
    [datetime] $Start,
    [datetime] $End,
    [string]   $ExportPath
)

Clear-Host
$Global:ScriptName = $MyInvocation.MyCommand.Name
$InitScript = "C:\DATA\Projects\GlobalSettings\SCRIPTS\Init.ps1"
if (. "$InitScript" -MyScriptRoot (Split-Path $PSCommandPath -Parent)) { exit 1 }
# Error trap
trap {
    if ($Global:Logger) {
      Get-ErrorReporting $_
        . "$GlobalSettings\$SCRIPTSFolder\Finish.ps1" 
        . "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"  
    }
    Else {
        Write-Host "There is error before logging initialized." -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################

$EventsLoaded = $false


if (Test-Path $OutputXMLPath) { 
    Remove-Item -Path $OutputXMLPath -Force
}

$Culture = Get-Culture 

[string]$Start = Get-Date $Start -format ($Culture.DateTimeFormat.SortableDateTimePattern )
[string]$End   = get-date $End -format ($Culture.DateTimeFormat.SortableDateTimePattern )

[string]$ScriptPath = "$MyScriptRoot\GetEventLogs.ps1"
[string]$Arguments = " -Start `"$Start`" -End `"$End`" -OutputXMLPath `"$OutputXMLPath`""

Start-PSScript -ScriptPath $ScriptPath -Arguments $Arguments -logFilePath $ScriptLogFilePath -Evaluate
if(test-path $OutputXMLPath){        
    [array]$EventArray = Import-Clixml -path $OutputXMLPath 
    $EventsLoaded = $true
}


if ($EventsLoaded){
    $EventArray | Select-Object TimeCreated, LevelDisplayName, LogName, ProviderName, Id, Message | Sort-Object TimeCreated, LogName | Format-Table -AutoSize
    $EventArray | Select-Object TimeCreated, LevelDisplayName, LogName, ProviderName, Id, Message | Sort-Object TimeCreated, LogName | Format-Table -AutoSize | Out-String | Set-Content -Path $ExportPath -Encoding utf8 

    $EventArray | Group-Object -Property LevelDisplayName, LogName -NoElement |
    Format-Table -AutoSize
    $EventArray | Group-Object -Property LevelDisplayName, LogName -NoElement |
    Format-Table -AutoSize | Out-String | Set-Content -Path $ExportPath -Encoding utf8 
}

################################# Script end here ###################################
. "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"