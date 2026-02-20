Param (
  [Parameter(Mandatory)]
  [ValidateSet("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Chinese (Simplified, China)", "Chinese (Traditional, Taiwan)", "Croatian (Croatia)", "Czech (Czech Republic)", "Danish (Denmark)", "Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, BokmÃ¥l (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)", "Keep current language (no change)")]
  [string]$a_windowsLanguage,

  # Controls whether the extra Office login prompt fix should run
  [Parameter()]
  [ValidateSet("yes", "no")]
  [string]$c_removeExtraOfficeLogin
)
# Issues: parameters & keyboard lay-out & location sso fix

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

if ($c_removeExtraOfficeLogin -eq "no") {
  Write-Host "=== Skipping extra Office login screen fix because c_removeExtraOfficeLogin=no ==="
}
else {
  Write-Host "=== Remove extra login screen for Office ==="
  & .\install_scripts\remove_extra_login_office.ps1
  Write-Host "=== Done with removing extra login screen for Office ==="
}

