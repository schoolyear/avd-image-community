Param (
    [Parameter(Mandatory = $true)]
    [string]$windowsLanguage
)

$ProgressPreference = 'SilentlyContinue'

# populate dictionary
$LanguagesDictionary = @{
    "Arabic (Saudi Arabia)"         = @{ Culture = "ar-SA"; GeoId = 205 }
    "Bulgarian (Bulgaria)"          = @{ Culture = "bg-BG"; GeoId = 35 }
    "Chinese (Simplified, China)"   = @{ Culture = "zh-CN"; GeoId = 45 }
    "Chinese (Traditional, Taiwan)" = @{ Culture = "zh-TW"; GeoId = 237 }
    "Croatian (Croatia)"            = @{ Culture = "hr-HR"; GeoId = 108 }
    "Czech (Czech Republic)"        = @{ Culture = "cs-CZ"; GeoId = 75 }
    "Danish (Denmark)"              = @{ Culture = "da-DK"; GeoId = 61 }
    "Dutch (Netherlands)"           = @{ Culture = "nl-NL"; GeoId = 176 }
    "English (United Kingdom)"      = @{ Culture = "en-GB"; GeoId = 242 }
    "English (Australia)"           = @{ Culture = "en-AU"; GeoId = 12 }
    "Estonian (Estonia)"            = @{ Culture = "et-EE"; GeoId = 70 }
    "Finnish (Finland)"             = @{ Culture = "fi-FI"; GeoId = 77 }
    "French (Canada)"               = @{ Culture = "fr-CA"; GeoId = 39 }
    "French (France)"               = @{ Culture = "fr-FR"; GeoId = 84 }
    "German (Germany)"              = @{ Culture = "de-DE"; GeoId = 94 }
    "Greek (Greece)"                = @{ Culture = "el-GR"; GeoId = 98 }
    "Hebrew (Israel)"               = @{ Culture = "he-IL"; GeoId = 117 }
    "Hungarian (Hungary)"           = @{ Culture = "hu-HU"; GeoId = 109 }
    "Italian (Italy)"               = @{ Culture = "it-IT"; GeoId = 118 }
    "Japanese (Japan)"              = @{ Culture = "ja-JP"; GeoId = 122 }
    "Korean (Korea)"                = @{ Culture = "ko-KR"; GeoId = 134 }
    "Latvian (Latvia)"              = @{ Culture = "lv-LV"; GeoId = 140 }
    "Lithuanian (Lithuania)"        = @{ Culture = "lt-LT"; GeoId = 141 }
    "Norwegian, Bokmål (Norway)"    = @{ Culture = "nb-NO"; GeoId = 177 }
    "Polish (Poland)"               = @{ Culture = "pl-PL"; GeoId = 191 }
    "Portuguese (Brazil)"           = @{ Culture = "pt-BR"; GeoId = 32 }
    "Portuguese (Portugal)"         = @{ Culture = "pt-PT"; GeoId = 193 }
    "Romanian (Romania)"            = @{ Culture = "ro-RO"; GeoId = 200 }
    "Russian (Russia)"              = @{ Culture = "ru-RU"; GeoId = 203 }
    "Serbian (Latin, Serbia)"       = @{ Culture = "sr-Latn-RS"; GeoId = 271 }
    "Slovak (Slovakia)"             = @{ Culture = "sk-SK"; GeoId = 143 }
    "Slovenian (Slovenia)"          = @{ Culture = "sl-SI"; GeoId = 212 }
    "Spanish (Mexico)"              = @{ Culture = "es-MX"; GeoId = 166 }
    "Spanish (Spain)"               = @{ Culture = "es-ES"; GeoId = 217 }
    "Swedish (Sweden)"              = @{ Culture = "sv-SE"; GeoId = 221 }
    "Thai (Thailand)"               = @{ Culture = "th-TH"; GeoId = 227 }
    "Turkish (Turkey)"              = @{ Culture = "tr-TR"; GeoId = 235 }
    "Ukrainian (Ukraine)"           = @{ Culture = "uk-UA"; GeoId = 241 }
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

function Write-TaskbarSwitcherKeyboardLayoutsToRegistry {
    $keyboardLayoutsKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts'
    $targetKeyPath = 'HKLM:\SOFTWARE\SchoolyearAVD\LanguageSupport'

    $languageList = Get-WinUserLanguageList -ErrorAction Stop
    if ($null -eq $languageList -or $languageList.Count -eq 0) {
        Write-Warning "Language installation: No user language list found when capturing taskbar switcher keyboard layouts"
        return
    }

    $switcherEntries = New-Object System.Collections.Generic.List[string]

    foreach ($language in $languageList) {
        $languageTag = $language.LanguageTag
        $inputMethodTips = @($language.InputMethodTips)

        if ($inputMethodTips.Count -eq 0) {
            $switcherEntries.Add(('{0} | (no InputMethodTips)' -f $languageTag))
            continue
        }

        foreach ($tip in $inputMethodTips) {
            $keyboardName = $null

            if ($tip -match '^[0-9A-Fa-f]{4}:(?<KeyboardLayoutId>[0-9A-Fa-f]{8})$') {
                $keyboardLayoutId = $Matches['KeyboardLayoutId']
                $layoutRegistryPath = Join-Path $keyboardLayoutsKeyPath $keyboardLayoutId

                try {
                    $layoutItem = Get-ItemProperty -Path $layoutRegistryPath -ErrorAction Stop
                    $keyboardName = $layoutItem.'Layout Text'
                }
                catch {
                    $keyboardName = $null
                }
            }

            if ([string]::IsNullOrWhiteSpace($keyboardName)) {
                $switcherEntries.Add(('{0} | {1}' -f $languageTag, $tip))
            }
            else {
                $switcherEntries.Add(('{0} | {1} | {2}' -f $languageTag, $tip, $keyboardName))
            }
        }
    }

    $uniqueEntries = $switcherEntries | Sort-Object -Unique

    New-Item -Path $targetKeyPath -Force | Out-Null
    New-ItemProperty -Path $targetKeyPath -Name 'TaskbarSwitcherKeyboardLayouts' -PropertyType MultiString -Value $uniqueEntries -Force | Out-Null
    New-ItemProperty -Path $targetKeyPath -Name 'TaskbarSwitcherKeyboardLayoutsCount' -PropertyType DWord -Value @($uniqueEntries).Count -Force | Out-Null

    Write-Host "Language installation: Wrote $(@($uniqueEntries).Count) taskbar switcher keyboard layout entries to $targetKeyPath"
}

#Set variables (change to your needs):
Write-Host "Language installation: setting variables"

$keepCurrentLanguage = $windowsLanguage -eq "Keep current language (no change)"

if ($keepCurrentLanguage) {
    Write-Host "Language installation: Keeping current language settings"
    $currentLanguageList = Get-WinUserLanguageList
    if ($null -eq $currentLanguageList -or $currentLanguageList.Count -eq 0) {
        throw "No existing user language list found while keep-current mode was requested."
    }

    $LPlanguage = $currentLanguageList[0].LanguageTag
    $geoId = (Get-WinHomeLocation).GeoId
    Write-Host "Language installation: current input locale is $LPlanguage"
    Write-Host "Language installation: current Geo id is $geoId "
}
else {
    $LPlanguage = $LanguagesDictionary[$windowsLanguage].Culture
    Write-Host "Language installation: Language tag is $LPlanguage "

    $geoId = $LanguagesDictionary[$windowsLanguage].GeoId
    Write-Host "Language installation: Geo id is $geoId "

    # Install an additional language pack including FODs after a delay to allow earlier updates to settle.
    Write-Host "Language installation: Starting 10-minute wait before installing language pack"
    Start-Sleep -Seconds 660
    Write-Host "Language installation: Installing languagepack"

    $transientRetryCount = 8
    $maxAttempts = 1 + $transientRetryCount
    $delaySeconds = 90
    $installed = $false

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        try {
            Write-Host "Language installation: Install-Language attempt $attempt/$maxAttempts for $LPlanguage"
            Install-Language $LPlanguage -CopyToSettings -ErrorAction Stop
            $installed = $true
            Write-Host "Language installation: Install-Language succeeded on attempt $attempt"
            break
        }
        catch {
            $hresultText = "n/a"
            if ($null -ne $_.Exception -and $null -ne $_.Exception.HResult) {
                $hresultText = ('0x{0:X8}' -f ($_.Exception.HResult -band 0xffffffff))
            }

            Write-Warning "Language installation: Install-Language failed on attempt $attempt/$maxAttempts. HResult=$hresultText Message=$($_.Exception.Message)"

            if ($attempt -lt $maxAttempts) {
                $nextAttempt = $attempt + 1
                $transientRetryIndex = $nextAttempt - 1
                Write-Host "Language installation: Retry $transientRetryIndex/$transientRetryCount"

                Write-Host "Language installation: Waiting $delaySeconds seconds before retry"
                Start-Sleep -Seconds $delaySeconds
            }
            else {
                throw
            }
        }
    }

    if (-not $installed) {
        throw "Language installation: Install-Language failed after $maxAttempts attempts for $LPlanguage"
    }


    #Check status of the installed language pack
    Write-Host "Language installation: Checking installed languagepack status"
    $installedLanguage = (Get-InstalledLanguage).LanguageId
    if ($installedLanguage -like $LPlanguage) {
        Write-Host "Language $LPlanguage installed"
    }
    else {
        Write-Host "Failure! Language $LPlanguage NOT installed"
        exit 1
    }

    #Set System Preferred UI Language
    Write-Host "Language installation: Setting SystemPreferredUILanguage $LPlanguage"
    Set-SystemPreferredUILanguage $LPlanguage

    # Configure new language defaults under current user (system) after which it can be copied to system
    #Set Win UI Language Override for regional changes
    Write-Host "Language installation: Setting WinUILanguageOverride $LPlanguage"
    Set-WinUILanguageOverride -Language $LPlanguage
}

if (-not $keepCurrentLanguage) {
    # Set Culture, sets the user culture for the current user account.
    Write-Host "Language installation: Setting culture $LPlanguage"
    Set-Culture -CultureInfo $LPlanguage

    # Set Win Home Location, sets the home location setting for the current user
    Write-Host "Language installation: Setting WinHomeLocation $geoId"
    Set-WinHomeLocation -GeoId $geoId
}

# Copy User International Settings from current user to System, including Welcome screen and new user
Write-Host "Language installation: Copy UserInternationalSettingsToSystem"
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
Write-TaskbarSwitcherKeyboardLayoutsToRegistry
# A restart is performed after all normal layers. So this script does not require one.

# Exit 0

