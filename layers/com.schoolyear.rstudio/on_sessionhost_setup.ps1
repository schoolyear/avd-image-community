# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptLogPrefix = "RStudio warm-up"
$rStudioPath = "C:\Program Files\RStudio\rstudio.exe"
$warmupSeconds = 90
$processDetectionSeconds = 0

# Start RStudio, then stop it after a delay. This reduces the time it takes for RStudio to start on first use by students.
if (!(Test-Path -LiteralPath $rStudioPath)) {
  Write-Warning "${scriptLogPrefix}: Skipping warm-up because $rStudioPath was not found."
  return
}

$existingRStudioProcessIds = @(
  Get-Process -Name "rstudio" -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Id
)

$newRStudioProcesses = @()

try {
  Write-Host "${scriptLogPrefix}: Starting RStudio to pre-initialize user data."
  Start-Process -FilePath $rStudioPath | Out-Null

  $rStudioStarted = $false
  for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 1
    $processDetectionSeconds++
    $newRStudioProcesses = @(
      Get-Process -Name "rstudio" -ErrorAction SilentlyContinue |
      Where-Object { $_.Id -notin $existingRStudioProcessIds }
    )

    if ($newRStudioProcesses.Count -gt 0) {
      $rStudioStarted = $true
      break
    }
  }

  if (-not $rStudioStarted) {
    Write-Warning "${scriptLogPrefix}: Skipping warm-up because no new RStudio process was detected after $processDetectionSeconds seconds."
    return
  }

  Write-Host "${scriptLogPrefix}: Letting RStudio run for $warmupSeconds seconds after startup was detected in $processDetectionSeconds seconds."
  Start-Sleep -Seconds $warmupSeconds
} catch {
  Write-Warning "${scriptLogPrefix}: Warm-up failed: $($_.Exception.Message)"
} finally {
  $newRStudioProcesses = @(
    Get-Process -Name "rstudio" -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -notin $existingRStudioProcessIds }
  )

  if ($newRStudioProcesses.Count -gt 0) {
    $newRStudioProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "${scriptLogPrefix}: Stopped warm-up RStudio processes after $warmupSeconds seconds of warm-up."
  }
}
