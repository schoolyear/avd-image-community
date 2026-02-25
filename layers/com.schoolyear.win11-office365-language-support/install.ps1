Param (
  [Parameter(Mandatory)]
  [ValidateSet("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Chinese (Simplified, China)", "Chinese (Traditional, Taiwan)", "Croatian (Croatia)", "Czech (Czech Republic)", "Danish (Denmark)", "Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, Bokmål (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)", "English (United States)")]
  [string]$windowsLanguage,

  [Parameter()]
  [ValidateSet("yes", "no")]
  [string]$removesPrivacyPopup
)

# Recommended snippet to make sure PowerShell stops execution on failure
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5#erroractionpreference
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.4
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Recommended snippet to make sure PowerShell doesn't show a progress bar when downloading files
# This makes the downloads considerably faster
$ProgressPreference = 'SilentlyContinue'

Write-Host "=== Change configuration file ==="
& .\install_scripts\change_office_configuration_file.ps1 -windowsLanguage $windowsLanguage
Write-Host "=== Done with changing configuration file ==="

Write-Host "=== Change office configuration ==="
& .\install_scripts\office_language.ps1
Write-Host "=== Done with changing office configuration ==="

if ($removesPrivacyPopup -eq "yes") {
  Write-Host "=== Removes 'Your Privacy Matters' pop-up ==="
  & .\install_scripts\remove_privacy_pop_up.ps1
  Write-Host "=== Done with removing 'Your Privacy Matters' pop-up ==="
}
