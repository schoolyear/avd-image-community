param (
  [switch]$RemoveInstaller
)

$scriptName = Split-Path -Path $PSCommandPath -Leaf

$vsCodeZipURL = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
$vsCodeZipName = "vscode.zip"
$vsCodeZipDownloadPath = "C:\${vsCodeZipName}"
$vsCodeZipExtractPath = "C:\VSCode"
$vsCodeSettingsPath = "C:\Users\Default\AppData\Roaming\Code"

#Downloads installer if necessary
if (!(Test-Path $vsCodeZipDownloadPath)) {
  Write-Host "VSCode installer not found, downloading..."
  try {
    Invoke-WebRequest -Uri $vsCodeZipURL -OutFile $vsCodeZipDownloadPath
  } catch {
    Write-Host "Failed to download VSCode : $_"
  }
} else {
  Write-Host "VSCode installer found, skipping download"
}

# If extracted vscode exists, remove
if (Test-Path $vsCodeZipExtractPath) {
  Write-Host "Found $vsCodeZipExtractPath, removing..."
  Remove-Item $vsCodeZipExtractPath -Force -Recurse | Out-Null
  Write-Host "Removed $vsCodeZipExtractPath"
}

#This extracts VS Code installation files
try {
  Write-Host "Extracting VSCode..."
  Expand-Archive $vsCodeZipDownloadPath $vsCodeZipExtractPath | Out-Null  
  Write-Host "Extracted VSCode"
} catch {
  Write-Host "Failed to extract VSCode: $_"
}

# This configures VS Code, a.o. it disables recommendation pop-ups, it trusts external files automatically, a theme is set-up, and the welcome walkthrough is disabled
try {
  Write-Host "Copying over data folder to $vsCodeSettingsPath..."
  Copy-Item ".\files\vscode\User" $vsCodeSettingsPath -Force -Recurse | Out-Null
  Write-Host "Successfully copied over data folder"
} catch {
  Write-Host "Failed to copy over data folder: $_"
}

#This removes the installer
if ($RemoveInstaller) {
  Write-Host "Removing downloaded installer (.zip file)"
  Remove-Item $vsCodeZipDownloadPath | Out-Null
  Write-Host "Successfully removed $vsCodeZipDownloadPath"
}