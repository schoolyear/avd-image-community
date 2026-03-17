$OdtExe = ".\resources\OfficeDeploymentTool.exe"
$TempPath = "."
$WorkingDir = (Resolve-Path $TempPath).Path
$scriptLogPrefix = "Office language"
Write-Host "${scriptLogPrefix}: Set Office Language started"
Write-Host "${scriptLogPrefix}: ODT exe path: $OdtExe"
Write-Host "${scriptLogPrefix}: Working directory: $((Get-Location).Path)"
Write-Host "${scriptLogPrefix}: Process working directory: $WorkingDir"
Write-Host "${scriptLogPrefix}: setup.exe expected at: $TempPath\setup.exe"
Write-Host "${scriptLogPrefix}: XML expected at: $TempPath\resources\M365Office.xml"

# Step 1: Extract ODT files
$extractArgs = "/quiet /extract:$TempPath"
Write-Host "${scriptLogPrefix}: Extract ODT files command: $OdtExe $extractArgs"
$extractProcess = Start-Process -FilePath $OdtExe -ArgumentList $extractArgs -WorkingDirectory $WorkingDir -Wait -PassThru -NoNewWindow
Write-Host "${scriptLogPrefix}: Extract ODT files exit code: $($extractProcess.ExitCode)"
if ($extractProcess.ExitCode -ne 0) {
  throw "${scriptLogPrefix}: Extract ODT files failed with exit code $($extractProcess.ExitCode)"
}

# Step 2: Run ODT with configuration
$configureExe = "$TempPath\setup.exe"
$configureArgs = "/configure $TempPath\resources\M365Office.xml"
Write-Host "${scriptLogPrefix}: Configure Office language command: $configureExe $configureArgs"
$configureProcess = Start-Process -FilePath $configureExe -ArgumentList $configureArgs -WorkingDirectory $WorkingDir -Wait -PassThru -NoNewWindow
Write-Host "${scriptLogPrefix}: Configure Office language exit code: $($configureProcess.ExitCode)"
if ($configureProcess.ExitCode -ne 0) {
  throw "${scriptLogPrefix}: Configure Office language failed with exit code $($configureProcess.ExitCode)"
}

Write-Host "${scriptLogPrefix}: Set Office Language completed"

