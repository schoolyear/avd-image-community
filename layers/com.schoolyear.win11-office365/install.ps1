# <CAN BE REMOVED>
# This script is executed during the preparation of the exam image
# This script is executed before the sysprep step
#
# This script is executed in its own layer folder
# So, any file in this image layer, is available in the current working directory
#
# Once all installation scripts are executed, all image layer files are deleted
# If you want to persist a file in the image, you must copy it to another folder
# </CAN BE REMOVED>

Param (
    # Controls whether the Office privacy scheduled task should be created
    [Parameter()]
    [ValidateSet("on", "off")]
    [string]$officePrivacyTask = "on",

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

# install.ps1
# Creates a scheduled task that runs at *user logon* (i.e., in the user's context)
# and sets: HKCU\Software\Microsoft\Office\16.0\Common\PrivacyDialogsDisabled=1

if ($officePrivacyTask -eq "off") {
  Write-Host "[OfficePrivacyTask] Skipping scheduled task creation because officePrivacyTask=off"
  exit 0
}

$TaskName = "SY-OfficePrivacyDialogsOnLogon"
$TaskPath = "\Schoolyear\"

Write-Host "[OfficePrivacyTask] Creating scheduled task: $TaskPath$TaskName"

# Run for the logged-on user (HKCU will be that user)
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

Write-Host "[OfficePrivacyTask] Scheduled task created."
Write-Host "[OfficePrivacyTask] Will run at logon in the user's context."


