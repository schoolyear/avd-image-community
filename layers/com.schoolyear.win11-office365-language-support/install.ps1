Param (
  [Parameter(Mandatory)]
  [ValidateSet("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Chinese (Simplified, China)", "Chinese (Traditional, Taiwan)", "Croatian (Croatia)", "Czech (Czech Republic)", "Danish (Denmark)", "Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, BokmÃ¥l (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)")]
  [string]$officeAppsLanguage,

  [Parameter()]
  [ValidateSet("yes", "no")]
  [string]$removeOfficePrivacyPopup
)

# Recommended snippet to make sure PowerShell stops execution on failure
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5#erroractionpreference
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.4
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Recommended snippet to make sure PowerShell doesn't show a progress bar when downloading files
# This makes the downloads considerably faster
$ProgressPreference = 'SilentlyContinue'
$scriptLogPrefix = "Office 365 language support install"

Write-Host "${scriptLogPrefix}: Change configuration file"
& .\install_scripts\change_office_configuration_file.ps1 -officeAppsLanguage $officeAppsLanguage
Write-Host "${scriptLogPrefix}: Done changing configuration file"

Write-Host "${scriptLogPrefix}: Change office configuration"
& .\install_scripts\office_language.ps1
Write-Host "${scriptLogPrefix}: Done changing office configuration"

if ($removeOfficePrivacyPopup -eq "yes") {
  Write-Host "${scriptLogPrefix}: Remove 'Your Privacy Matters' pop-up"
  & .\install_scripts\remove_privacy_pop_up.ps1
  Write-Host "${scriptLogPrefix}: Done removing 'Your Privacy Matters' pop-up"
}
