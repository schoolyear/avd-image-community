Param (
  [Parameter(Mandatory = $true)]
  [System.String[]]$LanguageList
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

# --- Settings ---
$GeoId = 176      # Netherlands

# populate dictionary
$LanguagesDictionary = @{}
$LanguagesDictionary.Add("Arabic (Saudi Arabia)", "ar-SA")
$LanguagesDictionary.Add("Bulgarian (Bulgaria)", "bg-BG")
$LanguagesDictionary.Add("Chinese (Simplified, China)", "zh-CN")
$LanguagesDictionary.Add("Chinese (Traditional, Taiwan)", "zh-TW")
$LanguagesDictionary.Add("Croatian (Croatia)",	"hr-HR")
$LanguagesDictionary.Add("Czech (Czech Republic)",	"cs-CZ")
$LanguagesDictionary.Add("Danish (Denmark)",	"da-DK")
$LanguagesDictionary.Add("Dutch (Netherlands)",	"nl-NL")
$LanguagesDictionary.Add("English (United States)",	"en-US")
$LanguagesDictionary.Add("English (United Kingdom)",	"en-GB")
$LanguagesDictionary.Add("Estonian (Estonia)",	"et-EE")
$LanguagesDictionary.Add("Finnish (Finland)",	"fi-FI")
$LanguagesDictionary.Add("French (Canada)",	"fr-CA")
$LanguagesDictionary.Add("French (France)",	"fr-FR")
$LanguagesDictionary.Add("German (Germany)",	"de-DE")
$LanguagesDictionary.Add("Greek (Greece)",	"el-GR")
$LanguagesDictionary.Add("Hebrew (Israel)",	"he-IL")
$LanguagesDictionary.Add("Hungarian (Hungary)",	"hu-HU")
$LanguagesDictionary.Add("Indonesian (Indonesia)",	"id-ID")
$LanguagesDictionary.Add("Italian (Italy)",	"it-IT")
$LanguagesDictionary.Add("Japanese (Japan)",	"ja-JP")
$LanguagesDictionary.Add("Korean (Korea)",	"ko-KR")
$LanguagesDictionary.Add("Latvian (Latvia)",	"lv-LV")
$LanguagesDictionary.Add("Lithuanian (Lithuania)",	"lt-LT")
$LanguagesDictionary.Add("Norwegian, Bokmål (Norway)",	"nb-NO")
$LanguagesDictionary.Add("Polish (Poland)",	"pl-PL")
$LanguagesDictionary.Add("Portuguese (Brazil)",	"pt-BR")
$LanguagesDictionary.Add("Portuguese (Portugal)",	"pt-PT")
$LanguagesDictionary.Add("Romanian (Romania)",	"ro-RO")
$LanguagesDictionary.Add("Russian (Russia)",	"ru-RU")
$LanguagesDictionary.Add("Serbian (Latin, Serbia)",	"sr-Latn-RS")
$LanguagesDictionary.Add("Slovak (Slovakia)",	"sk-SK")
$LanguagesDictionary.Add("Slovenian (Slovenia)",	"sl-SI")
$LanguagesDictionary.Add("Spanish (Mexico)",	"es-MX")
$LanguagesDictionary.Add("Spanish (Spain)",	"es-ES")
$LanguagesDictionary.Add("Swedish (Sweden)",	"sv-SE")
$LanguagesDictionary.Add("Thai (Thailand)",	"th-TH")
$LanguagesDictionary.Add("Turkish (Turkey)",	"tr-TR")
$LanguagesDictionary.Add("Ukrainian (Ukraine)",	"uk-UA")
$LanguagesDictionary.Add("English (Australia)",	"en-AU")

if ($LanguageList.Count -ne 1) {
  throw "Exactly one language is expected"
}

$LanguageCode = $LanguagesDictionary[$LanguageList[0]]

$Culture = $LanguageCode

$maxRetries = 5
$retryDelaySeconds = 15
$operations = @(
  @{
    Name   = "Set-WinSystemLocale"
    Action = { Set-WinSystemLocale -SystemLocale $Culture -ErrorAction Stop }
  },
  @{
    Name   = "Set-WinHomeLocation"
    Action = { Set-WinHomeLocation -GeoId $GeoId -ErrorAction Stop }
  },
  @{
    Name   = "Set-SystemPreferredUILanguage"
    Action = { Set-SystemPreferredUILanguage -Language $Culture -ErrorAction Stop }
  }
)

foreach ($op in $operations) {
  $succeeded = $false

  for ($i = 1; $i -le $maxRetries; $i++) {
    try {
      Write-Host "*** $($op.Name) attempt $i ***"
      & $op.Action
      Write-Host "*** $($op.Name) succeeded ***"
      $succeeded = $true
      break
    }
    catch {
      Write-Host "*** $($op.Name) failed on attempt $($i): [$($_.Exception.Message)] ***"
      if ($i -lt $maxRetries) {
        Start-Sleep -Seconds $retryDelaySeconds
      }
    }
  }

  if (-not $succeeded) {
    Write-Host "*** $($op.Name) failed after $maxRetries attempts ***"
    Get-InstalledLanguage
    exit 1
  }
}

try {
  if (-not (Test-Command "Copy-UserInternationalSettingsToSystem")) {
    throw "Copy-UserInternationalSettingsToSystem not available"
  }

  Copy-UserInternationalSettingsToSystem -NewUser $true -WelcomeScreen $true
  Write-Host "***Copy-UserInternationalSettingsToSystem succeeded."
}
catch {
  Write-Host "Copy settings failed"
}
