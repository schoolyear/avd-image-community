$OdtExe = ".\resources\OfficeDeploymentTool.exe"
$TempPath = "."
$scriptLogPrefix = "Office language"
Write-Host "${scriptLogPrefix}: Set Office Language started"
Write-Host "${scriptLogPrefix}: ODT exe path: $OdtExe"

# Step 1: Extract ODT files
$extractArgs = "/quiet /extract:$TempPath"
Write-Host "${scriptLogPrefix}: Extract ODT files command: $OdtExe $extractArgs"
$extractProcess = Start-Process -FilePath $OdtExe -ArgumentList $extractArgs -Wait -PassThru -NoNewWindow
Write-Host "${scriptLogPrefix}: Extract ODT files exit code: $($extractProcess.ExitCode)"

# Step 2: Run ODT with configuration
$configureExe = "$TempPath\setup.exe"
$configureArgs = "/configure $TempPath\resources\M365Office.xml"
Write-Host "${scriptLogPrefix}: Configure Office language command: $configureExe $configureArgs"
$configureProcess = Start-Process -FilePath $configureExe -ArgumentList $configureArgs -Wait -PassThru -NoNewWindow
Write-Host "${scriptLogPrefix}: Configure Office language exit code: $($configureProcess.ExitCode)"

Write-Host "${scriptLogPrefix}: Set Office Language completed"

