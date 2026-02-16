Param (
    [Parameter(Mandatory = $true)]
    [string]$windowsLanguage
)

$ProgressPreference = 'SilentlyContinue'

# populate dictionary
$LanguagesDictionary = @{
    "Arabic (Saudi Arabia)"               = @{ Culture = "ar-SA"; GeoId = 205 }
    "Bulgarian (Bulgaria)"                = @{ Culture = "bg-BG"; GeoId = 35 }
    "Chinese (Simplified, China)"          = @{ Culture = "zh-CN"; GeoId = 45 }
    "Chinese (Traditional, Taiwan)"        = @{ Culture = "zh-TW"; GeoId = 237 }
    "Croatian (Croatia)"                  = @{ Culture = "hr-HR"; GeoId = 108 }
    "Czech (Czech Republic)"               = @{ Culture = "cs-CZ"; GeoId = 75 }
    "Danish (Denmark)"                    = @{ Culture = "da-DK"; GeoId = 61 }
    "Dutch (Netherlands)"                 = @{ Culture = "nl-NL"; GeoId = 176 }
    "English (United States)"              = @{ Culture = "en-US"; GeoId = 244 }
    "English (United Kingdom)"             = @{ Culture = "en-GB"; GeoId = 242 }
    "English (Australia)"                  = @{ Culture = "en-AU"; GeoId = 12 }
    "Estonian (Estonia)"                   = @{ Culture = "et-EE"; GeoId = 70 }
    "Finnish (Finland)"                   = @{ Culture = "fi-FI"; GeoId = 77 }
    "French (Canada)"                     = @{ Culture = "fr-CA"; GeoId = 39 }
    "French (France)"                     = @{ Culture = "fr-FR"; GeoId = 84 }
    "German (Germany)"                    = @{ Culture = "de-DE"; GeoId = 94 }
    "Greek (Greece)"                      = @{ Culture = "el-GR"; GeoId = 98 }
    "Hebrew (Israel)"                     = @{ Culture = "he-IL"; GeoId = 117 }
    "Hungarian (Hungary)"                 = @{ Culture = "hu-HU"; GeoId = 109 }
    "Indonesian (Indonesia)"              = @{ Culture = "id-ID"; GeoId = 111 }
    "Italian (Italy)"                     = @{ Culture = "it-IT"; GeoId = 118 }
    "Japanese (Japan)"                    = @{ Culture = "ja-JP"; GeoId = 122 }
    "Korean (Korea)"                      = @{ Culture = "ko-KR"; GeoId = 134 }
    "Latvian (Latvia)"                    = @{ Culture = "lv-LV"; GeoId = 140 }
    "Lithuanian (Lithuania)"              = @{ Culture = "lt-LT"; GeoId = 141 }
    "Norwegian, Bokmål (Norway)"           = @{ Culture = "nb-NO"; GeoId = 177 }
    "Polish (Poland)"                     = @{ Culture = "pl-PL"; GeoId = 191 }
    "Portuguese (Brazil)"                 = @{ Culture = "pt-BR"; GeoId = 32 }
    "Portuguese (Portugal)"               = @{ Culture = "pt-PT"; GeoId = 193 }
    "Romanian (Romania)"                  = @{ Culture = "ro-RO"; GeoId = 200 }
    "Russian (Russia)"                    = @{ Culture = "ru-RU"; GeoId = 203 }
    "Serbian (Latin, Serbia)"             = @{ Culture = "sr-Latn-RS"; GeoId = 271 }
    "Slovak (Slovakia)"                   = @{ Culture = "sk-SK"; GeoId = 143 }
    "Slovenian (Slovenia)"                = @{ Culture = "sl-SI"; GeoId = 212 }
    "Spanish (Mexico)"                    = @{ Culture = "es-MX"; GeoId = 166 }
    "Spanish (Spain)"                     = @{ Culture = "es-ES"; GeoId = 217 }
    "Swedish (Sweden)"                    = @{ Culture = "sv-SE"; GeoId = 221 }
    "Thai (Thailand)"                     = @{ Culture = "th-TH"; GeoId = 227 }
    "Turkish (Turkey)"                    = @{ Culture = "tr-TR"; GeoId = 235 }
    "Ukrainian (Ukraine)"                 = @{ Culture = "uk-UA"; GeoId = 241 }
}
# Language tag can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows
# A list of input locales can be found here: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
# GeoID can be found here: https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations?redirectedfrom=MSDN

Write-Host "Change Office configuration file: setting variable"

$odtLang = $LanguagesDictionary[$windowsLanguage].Culture.ToLowerInvariant()

Write-Host "Language installation: Language tag is $LPlanguage "
(Get-Content $TemplateXmlPath -Raw).Replace("__ODT_LANG__", $odtLang) |
  Set-Content -LiteralPath $OutXmlPath -Encoding UTF8
