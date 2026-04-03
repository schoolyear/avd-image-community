param (
  [Parameter(Mandatory = $true)]
  [string]$vsCodeVersion,

  [switch]$RemoveInstaller
)

$scriptName = Split-Path -Path $PSCommandPath -Leaf

$vsCodeZipURL = "https://update.code.visualstudio.com/$vsCodeVersion/win32-x64-archive/stable"
$vsCodeZipName = "VSCode-$vsCodeVersion-win32-x64-archive.zip"
$vsCodeZipDownloadPath = "C:\${vsCodeZipName}"
$vsCodeZipExtractPath = "C:\VSCode"
$vsCodeSettingsPath = "C:\Users\Default\AppData\Roaming\Code"

#Downloads installer
Write-Host "Downloading VSCode installer from $vsCodeZipURL to $vsCodeZipDownloadPath"
Invoke-WebRequest -Uri $vsCodeZipURL -OutFile $vsCodeZipDownloadPath

if (!(Test-Path $vsCodeZipDownloadPath)) {
  throw "VSCode installer was not found at $vsCodeZipDownloadPath after download"
}

# If extracted vscode exists, remove
if (Test-Path $vsCodeZipExtractPath) {
  Write-Host "Found $vsCodeZipExtractPath, removing..."
  Remove-Item $vsCodeZipExtractPath -Force -Recurse | Out-Null
  Write-Host "Removed $vsCodeZipExtractPath"
}

#This extracts VS Code installation files
Write-Host "Extracting VSCode from $vsCodeZipDownloadPath to $vsCodeZipExtractPath"
Expand-Archive $vsCodeZipDownloadPath $vsCodeZipExtractPath | Out-Null

if (!(Test-Path "$vsCodeZipExtractPath\Code.exe")) {
  throw "VSCode executable was not found at $vsCodeZipExtractPath\Code.exe after extraction"
}

Write-Host "Extracted VSCode"

# This configures VS Code, a.o. it disables recommendation pop-ups, it trusts external files automatically, a theme is set-up, and the welcome walkthrough is disabled
Write-Host "Copying over data folder to $vsCodeSettingsPath..."
Copy-Item ".\files\vscode\User" $vsCodeSettingsPath -Force -Recurse | Out-Null

if (!(Test-Path "$vsCodeSettingsPath\User\settings.json")) {
  throw "VSCode user settings were not found at $vsCodeSettingsPath\User\settings.json after copying"
}

Write-Host "Successfully copied over data folder"

#This removes the installer
if ($RemoveInstaller) {
  Write-Host "Removing downloaded installer (.zip file)"
  Remove-Item $vsCodeZipDownloadPath | Out-Null
  Write-Host "Successfully removed $vsCodeZipDownloadPath"
}
