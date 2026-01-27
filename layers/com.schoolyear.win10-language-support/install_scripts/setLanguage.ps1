$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

# --- Settings ---
$GeoId   = 176      # Netherlands
$Culture = "nl-NL"  # formats/locale


try { Set-WinSystemLocale $Culture } catch { Write-Host "***Set-WinSystemLocale failed (non-fatal): $($_.Exception.Message)" }
try { Set-WinHomeLocation -GeoId $GeoId } catch { Write-Host "***Set-WinHomeLocation failed (non-fatal): $($_.Exception.Message)" }
try { Set-SystemPreferredUILanguage -Language $Culture } catch { Write-Host "***Set-SystemPreferredUILanguage failed (non-fatal): $($_.Exception.Message)" }

# Preferred: cmdlet; Fallback: intl.xml via control.exe
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
