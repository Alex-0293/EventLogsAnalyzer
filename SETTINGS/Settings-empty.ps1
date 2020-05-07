# Rename this file to Settings.ps1
######################### Script params #########################
    [String]$Global:APP_SCRIPT_ADMIN_Login = ""          # AES login file path.
    [String]$Global:APP_SCRIPT_ADMIN_Pass  = ""          # AES password file path.
######################### no replacement ########################

[bool] $Global:LocalSettingsSuccessfullyLoaded = $true
# Error trap
trap {
    $Global:LocalSettingsSuccessfullyLoaded = $False
    exit 1
}
######################### local section  ########################
