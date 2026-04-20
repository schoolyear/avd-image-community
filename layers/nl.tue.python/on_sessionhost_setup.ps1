# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Block inbound traffic for VS Code to suppress the Windows Firewall prompt on first run.
$firewallRuleName = "nl.tue.python.vscode.block-inbound"
$scriptLogPrefix = "VSCode warm-up"
$vsCodePath = "C:\VSCode\Code.exe"
$warmupSeconds = 90
$processDetectionSeconds = 0

if (-not (Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule `
    -Name $firewallRuleName `
    -DisplayName "TUE Python layer - Block inbound Visual Studio Code" `
    -Direction Inbound `
    -Action Block `
    -Program "C:\VSCode\Code.exe" `
    -Profile Any | Out-Null
}

if (!(Test-Path -LiteralPath $vsCodePath)) {
  Write-Warning "${scriptLogPrefix}: Skipping warm-up because $vsCodePath was not found."
  return
}

$existingCodeProcessIds = @(
  Get-Process -Name "Code" -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Id
)

$newCodeProcesses = @()

try {
  Write-Host "${scriptLogPrefix}: Starting VSCode to pre-initialize portable data."
  Start-Process -FilePath $vsCodePath -ArgumentList "--new-window" | Out-Null

  $codeStarted = $false
  for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 1
    $processDetectionSeconds++
    $newCodeProcesses = @(
      Get-Process -Name "Code" -ErrorAction SilentlyContinue |
      Where-Object { $_.Id -notin $existingCodeProcessIds }
    )

    if ($newCodeProcesses.Count -gt 0) {
      $codeStarted = $true
      break
    }
  }

  if (-not $codeStarted) {
    Write-Warning "${scriptLogPrefix}: Skipping warm-up because no new VSCode process was detected after $processDetectionSeconds seconds."
    return
  }

  Write-Host "${scriptLogPrefix}: Letting VSCode run for $warmupSeconds seconds after startup was detected in $processDetectionSeconds seconds."
  Start-Sleep -Seconds $warmupSeconds
} catch {
  Write-Warning "${scriptLogPrefix}: Warm-up failed: $($_.Exception.Message)"
} finally {
  $newCodeProcesses = @(
    Get-Process -Name "Code" -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -notin $existingCodeProcessIds }
  )

  if ($newCodeProcesses.Count -gt 0) {
    $newCodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "${scriptLogPrefix}: Stopped warm-up VSCode processes after $warmupSeconds seconds of warm-up."
  }
}
