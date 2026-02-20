Param (
    [Parameter(Mandatory = $true)]
    [string]$windowsLanguage,
    [Parameter(Mandatory = $false)]
    [ValidateSet("Default for language", "English (United States) - US International")]
    [string]$keyboardLayout = "Default for language"
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

# ------------------------------------------------------------------------------------------------------------ #
# Author(s)    : Peter Klapwijk - www.inthecloud247.com                                                        #
# Version      : 1.1                                                                                           #
#                                                                                                              #
# Description  : Install an additional language pack during Autopilot ESP.                                     #
#                Changes language for new users, welcome screen etc.                                           #
#                Uses PowerShell commands only Supported on Windows 11 22H2 and later                          #
#                                                                                                              #
# Changes      : v1.0 - Initial version                                                                		   # 
#                v1.1 - Split up language pack and input locale language as these are not always the same      #
#                                                                                                              #
#                This script is provide "As-Is" without any warranties                                 		   #
#                                                                                                              #
#------------------------------------------------------------------------------------------------------------- #

# ------------------------------------------------------------------------------------------------------------ #
# The script was adapted to fit Schoolyear AVD and allow for parameters to change to 'any' language.           #
#------------------------------------------------------------------------------------------------------------- #

# Microsoft Intune Management Extension might start a 32-bit PowerShell instance. If so, restart as 64-bit PowerShell
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}

#Set variables (change to your needs):
Write-Host "Language installation: setting variables"

$LPlanguage = $LanguagesDictionary[$windowsLanguage].Culture
Write-Host "Language installation: Language tag is $LPlanguage "
# As In some countries the input locale might differ from the installed language pack language, we use a separate input local variable.

$inputlocale = $LanguagesDictionary[$windowsLanguage].Culture
Write-Host "Language installation: input locale is $inputlocale "
Write-Host "Language installation: keyboard layout option is $keyboardLayout "

$geoId = $LanguagesDictionary[$windowsLanguage].GeoId
Write-Host "Language installation: Geo id is $geoId "

#Install language pack and change the language of the OS on different places

#Install an additional language pack including FODs
Write-Host "Language installation: Installing languagepack"

Install-Language $LPlanguage -CopyToSettings

#Check status of the installed language pack
Write-Host "Language installation: Checking installed languagepack status"
$installedLanguage = (Get-InstalledLanguage).LanguageId

if ($installedLanguage -like $LPlanguage){
	Write-Host "Language $LPlanguage installed"
	}
	else {
	Write-Host "Failure! Language $LPlanguage NOT installed"
    Exit 1
}

#Set System Preferred UI Language
Write-Host "Language installation: Setting SystemPreferredUILanguage $inputlocale"
Set-SystemPreferredUILanguage $inputlocale

# Configure new language defaults under current user (system) after which it can be copied to system
#Set Win UI Language Override for regional changes
Write-Host "Language installation: Setting WinUILanguageOverride $inputlocale"
Set-WinUILanguageOverride -Language $inputlocale

# Set Win User Language List, sets the current user language settings
Write-Host "Language installation: Setting WinUserLanguageList"
$OldList = Get-WinUserLanguageList
$UserLanguageList = New-WinUserLanguageList -Language $inputlocale
$UserLanguageList += $OldList | where { $_.LanguageTag -ne $inputlocale }
$UserLanguageList | select LanguageTag
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force

# Ensure keyboard/input default follows the target language instead of a prior fallback (for example en-US)
Write-Host "Language installation: Setting WinDefaultInputMethodOverride"
$AppliedList = Get-WinUserLanguageList
$PrimaryEntry = $AppliedList | Where-Object { $_.LanguageTag -eq $inputlocale } | Select-Object -First 1
$defaultInputTip = $null

if ($null -ne $PrimaryEntry -and $null -ne $PrimaryEntry.InputMethodTips -and $PrimaryEntry.InputMethodTips.Count -gt 0) {
    $defaultInputTip = $PrimaryEntry.InputMethodTips[0]
}
else {
    # Fallback: derive a keyboard TIP from locale metadata if InputMethodTips is not populated yet
    $cultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo($inputlocale)
    $langHex = $cultureInfo.LCID.ToString("X4")
    $layoutHex = $cultureInfo.KeyboardLayoutId.ToString("X8")
    $defaultInputTip = "$langHex`:$layoutHex"
}

if ($keyboardLayout -eq "English (United States) - US International") {
    # en-US International keyboard layout (TIP)
    $defaultInputTip = "0409:00020409"
}

Write-Host "Language installation: Default InputTip is $defaultInputTip"
Set-WinDefaultInputMethodOverride -InputTip $defaultInputTip
$currentInputOverride = Get-WinDefaultInputMethodOverride
Write-Host "Language installation: WinDefaultInputMethodOverride is $($currentInputOverride.InputTip)"

# Set Culture, sets the user culture for the current user account.
Write-Host "Language installation: Setting culture $inputlocale"
Set-Culture -CultureInfo $inputlocale

# Set Win Home Location, sets the home location setting for the current user 
Write-Host "Language installation: Setting WinHomeLocation $geoId"
Set-WinHomeLocation -GeoId $geoId

# Copy User International Settings from current user to System, including Welcome screen and new user
Write-Host "Language installation: Copy UserInternationalSettingsToSystem"
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True

# A restart is performed after all normal layers. So this script does not require one.

# Exit 0

