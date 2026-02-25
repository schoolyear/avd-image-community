$OdtExe = ".\resources\OfficeDeploymentTool.exe"
$TempPath = "."
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Set Office Language started ***"
Write-Host "*** AVD AIB CUSTOMIZER PHASE : $OdtExe ***"

# Step 1: Extract ODT files
$extractArgs = "/quiet /extract:$TempPath"
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Extract ODT files command: $OdtExe $extractArgs ***"
$extractProcess = Start-Process -FilePath $OdtExe -ArgumentList $extractArgs -Wait -PassThru -NoNewWindow
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Extract ODT files exit code: $($extractProcess.ExitCode) ***"

# Step 2: Run ODT with configuration
$configureExe = "$TempPath\setup.exe"
$configureArgs = "/configure $TempPath\resources\M365Office.xml"
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Configure Office language command: $configureExe $configureArgs ***"
$configureProcess = Start-Process -FilePath $configureExe -ArgumentList $configureArgs -Wait -PassThru -NoNewWindow
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Configure Office language exit code: $($configureProcess.ExitCode) ***"

Write-Host "*** AVD AIB CUSTOMIZER PHASE : Set Office Language completed ***"

