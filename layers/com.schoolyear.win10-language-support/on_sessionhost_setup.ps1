# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# --- Settings ---
$GeoId   = 176      # Netherlands
$Culture = "nl-NL"  # formats/locale

$KeyboardId  = "00020409"   # US keyboard

#redundant

try { get-WinSystemLocale } catch { Write-Host "***Get-WinSystemLocale failed (non-fatal): $($_.Exception.Message)" }
try { get-WinHomeLocation } catch { Write-Host "***Get-WinHomeLocation failed (non-fatal): $($_.Exception.Message)" }
try { get-SystemPreferredUILanguage } catch { Write-Host "***Get-SystemPreferredUILanguage failed (non-fatal): $($_.Exception.Message)" }
get-Culture

try { Set-WinSystemLocale $Culture } catch { Write-Host "***Set-WinSystemLocale failed (non-fatal): $($_.Exception.Message)" }
try { Set-WinHomeLocation -GeoId $GeoId } catch { Write-Host "***Set-WinHomeLocation failed (non-fatal): $($_.Exception.Message)" }
try { Set-SystemPreferredUILanguage -Language $Culture } catch { Write-Host "***Set-SystemPreferredUILanguage failed (non-fatal): $($_.Exception.Message)" }

try { get-WinSystemLocale } catch { Write-Host "***Get-WinSystemLocale failed (non-fatal): $($_.Exception.Message)" }
try { get-WinHomeLocation } catch { Write-Host "***Get-WinHomeLocation failed (non-fatal): $($_.Exception.Message)" }
try { get-SystemPreferredUILanguage } catch { Write-Host "***Get-SystemPreferredUILanguage failed (non-fatal): $($_.Exception.Message)" }
set-Culture nl-NL
