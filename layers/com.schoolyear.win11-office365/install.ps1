Param (
    # Controls whether the "Your Privacy Matters pop-up is removed"
    [Parameter()]
    [ValidateSet("yes", "no")]
    [string]$removesPrivacyPopup,

    # You can configure your own parameter in the properties.json5 file
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs                    # To make sure this script doesn't break when new parameters are added
)

# Recommended snippet to make sure PowerShell stops execution on failure
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5#erroractionpreference
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.4
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Recommended snippet to make sure PowerShell doesn't show a progress bar when downloading files
# This makes the downloads considerably faster
$ProgressPreference = 'SilentlyContinue'

# The script creates a scheduled task that runs at *user logon* (i.e., in the user's context)
# and sets: HKCU\Software\Microsoft\Office\16.0\Common\PrivacyDialogsDisabled=1

#Skips this script if the parameter is set to "no"
if ($removesPrivacyPopup -eq "no") {
  Write-Host "[removesPrivacyPopup] Skipping script because removesPrivacyPopup=no"
  exit 0
}

$TaskName = "SY-OfficePrivacyDialogRemoval"
$TaskPath = "\Schoolyear\"

Write-Host "[removesPrivacyPopup] Creating scheduled task: $TaskPath$TaskName"

$Command = 'reg.exe add "HKCU\Software\Microsoft\Office\16.0\Common" /v PrivacyDialogsDisabled /t REG_DWORD /d 1 /f'
$Action    = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $Command"
$Trigger   = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited
$Settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask `
  -TaskName $TaskName `
  -TaskPath $TaskPath `
  -Action $Action `
  -Trigger $Trigger `
  -Principal $Principal `
  -Settings $Settings | Out-Null

Write-Host "[removesPrivacyPopup] Scheduled task created."
Write-Host "[removesPrivacyPopup] Will run at logon in the user's context."


