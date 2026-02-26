Param (
    [Parameter(Mandatory = $true)]
    [string]$officeAppsLanguage
)

$ProgressPreference = 'SilentlyContinue'

# Map display names to Office Deployment Tool language tags.
$LanguagesDictionary = @{
    "Arabic (Saudi Arabia)"          = @{ Culture = "ar-SA" }
    "Bulgarian (Bulgaria)"           = @{ Culture = "bg-BG" }
    "Chinese (Simplified, China)"    = @{ Culture = "zh-CN" }
    "Chinese (Traditional, Taiwan)"  = @{ Culture = "zh-TW" }
    "Croatian (Croatia)"             = @{ Culture = "hr-HR" }
    "Czech (Czech Republic)"         = @{ Culture = "cs-CZ" }
    "Danish (Denmark)"               = @{ Culture = "da-DK" }
    "Dutch (Netherlands)"            = @{ Culture = "nl-NL" }
    "English (United Kingdom)"       = @{ Culture = "en-GB" }
    "English (Australia)"            = @{ Culture = "en-AU" }
    "Estonian (Estonia)"             = @{ Culture = "et-EE" }
    "Finnish (Finland)"              = @{ Culture = "fi-FI" }
    "French (Canada)"                = @{ Culture = "fr-CA" }
    "French (France)"                = @{ Culture = "fr-FR" }
    "German (Germany)"               = @{ Culture = "de-DE" }
    "Greek (Greece)"                 = @{ Culture = "el-GR" }
    "Hebrew (Israel)"                = @{ Culture = "he-IL" }
    "Hungarian (Hungary)"            = @{ Culture = "hu-HU" }
    "Italian (Italy)"                = @{ Culture = "it-IT" }
    "Japanese (Japan)"               = @{ Culture = "ja-JP" }
    "Korean (Korea)"                 = @{ Culture = "ko-KR" }
    "Latvian (Latvia)"               = @{ Culture = "lv-LV" }
    "Lithuanian (Lithuania)"         = @{ Culture = "lt-LT" }
    "Norwegian, Bokmål (Norway)"    = @{ Culture = "nb-NO" }
    "Polish (Poland)"                = @{ Culture = "pl-PL" }
    "Portuguese (Brazil)"            = @{ Culture = "pt-BR" }
    "Portuguese (Portugal)"          = @{ Culture = "pt-PT" }
    "Romanian (Romania)"             = @{ Culture = "ro-RO" }
    "Russian (Russia)"               = @{ Culture = "ru-RU" }
    "Serbian (Latin, Serbia)"        = @{ Culture = "sr-Latn-RS" }
    "Slovak (Slovakia)"              = @{ Culture = "sk-SK" }
    "Slovenian (Slovenia)"           = @{ Culture = "sl-SI" }
    "Spanish (Mexico)"               = @{ Culture = "es-MX" }
    "Spanish (Spain)"                = @{ Culture = "es-ES" }
    "Swedish (Sweden)"               = @{ Culture = "sv-SE" }
    "Thai (Thailand)"                = @{ Culture = "th-TH" }
    "Turkish (Turkey)"               = @{ Culture = "tr-TR" }
    "Ukrainian (Ukraine)"            = @{ Culture = "uk-UA" }
}
# Language tags can be found here:
# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows

Write-Host "Change Office configuration file: setting variable"

$odtLang = $LanguagesDictionary[$officeAppsLanguage].Culture.ToLowerInvariant()

Write-Host "Change Office configuration file: odtLang is $odtLang "
$TemplateXmlPath = ".\resources\M365OfficeTemplate.xml"
$OutXmlPath = ".\resources\M365Office.xml"

(Get-Content $TemplateXmlPath -Raw).Replace("__ODT_LANG__", $odtLang) |
  Set-Content -LiteralPath $OutXmlPath -Encoding UTF8
Write-Host "Change Office configuration file: Changed language in config file"
