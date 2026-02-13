$TempPath = "."
$OdtExe = "$TempPath\OfficeDeploymentTool.exe"

Write-Host "*** AVD AIB CUSTOMIZER PHASE : Set Office Language started ***"
Write-Host "*** AVD AIB CUSTOMIZER PHASE : $OdtExe ***"

# Step 1: Extract ODT files
Start-Process -FilePath $OdtExe -ArgumentList "/quiet /extract:$TempPath" -Wait -NoNewWindow

# Step 2: Run ODT with configuration

Start-Process "$TempPath\setup.exe" "/configure $TempPath\M365OfficeNL.xml" -Wait -PassThru -NoNewWindow
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Start-Process "$TempPath\setup.exe" "/configure $TempPath\M365OfficeNL.xml" ***"

Write-Host "*** AVD AIB CUSTOMIZER PHASE : Set Office Language completed ***"

