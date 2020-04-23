<#
    .SYNOPSIS 
        Creator
        dd.MM.yyyy
        Ver
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
$ImportResult = Import-Module AlexkUtils  -PassThru -force
if ($null -eq $ImportResult) {
    Write-Host "Module 'AlexkUtils' does not loaded!" -ForegroundColor Red
    exit 1
}
else {
    $ImportResult = $null
}
#requires -version 3

#########################################################################
function Get-WorkDir () {
    if ($PSScriptRoot -eq "") {
        if ($PWD -ne "") {
            $MyScriptRoot = $PWD
        }        
        else {
            Write-Host "Where i am? What is my work dir?"
        }
    }
    else {
        $MyScriptRoot = $PSScriptRoot
    }
    return $MyScriptRoot
}
Function Initialize-Script   () {
    [string]$Global:MyScriptRoot = Get-WorkDir
    [string]$Global:GlobalSettingsPath = "C:\DATA\Projects\GlobalSettings\SETTINGS\Settings.ps1"

    Get-SettingsFromFile -SettingsFile $Global:GlobalSettingsPath
    if ($GlobalSettingsSuccessfullyLoaded) {    
        Get-SettingsFromFile -SettingsFile "$ProjectRoot\$($Global:SETTINGSFolder)\Settings.ps1"
        if ($Global:LocalSettingsSuccessfullyLoaded) {
            Initialize-Logging   "$ProjectRoot\$LOGSFolder\$ErrorsLogFileName" "Latest"
            Write-Host "Logging initialized."            
        }
        Else {
            Add-ToLog -Message "[Error] Error loading local settings!" -logFilePath "$(Split-Path -path $Global:MyScriptRoot -parent)\$LOGSFolder\$ErrorsLogFileName" -Display -Status "Error" -Format 'yyyy-MM-dd HH:mm:ss'
            Exit 1 
        }
    }
    Else { 
        Add-ToLog -Message "[Error] Error loading global settings!" -logFilePath "$(Split-Path -path $Global:MyScriptRoot -parent)\LOGS\Errors.log" -Display -Status "Error" -Format 'yyyy-MM-dd HH:mm:ss'
        Exit 1
    }
}
# Error trap
trap {
    Get-ErrorReporting $_    
    exit 1
}
#########################################################################
Clear-Host
Initialize-Script

$ScriptBlock = {
    $Start = (Get-Date).AddSeconds(-10)
    $Logs =  Get-WinEvent -ListLog *  
    [array]$Res = @()        
    Foreach($Log in $Logs) {           
        $Log.LogName
        $Filter = @{
            LogName            = $Log.LogName
            StartTime          = $Start
        }
        $Res += Get-WinEvent -FilterHashTable $Filter -ErrorAction SilentlyContinue
    }    
}

$EventsLoaded = $false

$User = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Login
$Pass = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Pass

if ($user) {
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList (Get-VarToString $User), $Pass

    Start-PSScript -ScriptBlock $ScriptBlock -Credentials $Credentials -logFilePath $ScriptLogFilePath  -Evaluate | Out-Null
    if(test-path $OutputXMLPath){        
        [array]$EventArray = Import-Clixml -path $OutputXMLPath 
        $EventsLoaded = $true
    }
}

if ($EventsLoaded){
    $EventArray | Select-Object TimeCreated, LevelDisplayName, LogName, ProviderName, Id, Message | Sort-Object TimeCreated, LogName| Format-Table -AutoSize 

    $EventArray | Group-Object -Property LevelDisplayName, LogName -NoElement |
    Format-Table -AutoSize
}
