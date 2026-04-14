param (
  [Parameter(Mandatory = $true)]
  [string]$vsCodeVersion,

  [switch]$RemoveInstaller
)

$scriptName = Split-Path -Path $PSCommandPath -Leaf
$scriptLogPrefix = "VSCode"

function New-Shortcut {
  param (
    [Parameter(Mandatory = $true)]
    [string]$shortcutPath,

    [Parameter(Mandatory = $true)]
    [string]$targetPath
  )

  $shortcutDirectory = Split-Path -Path $shortcutPath -Parent
  if (!(Test-Path $shortcutDirectory)) {
    New-Item -Path $shortcutDirectory -ItemType Directory -Force | Out-Null
  }

  $wScriptShell = New-Object -ComObject WScript.Shell
  $shortcut = $wScriptShell.CreateShortcut($shortcutPath)
  $shortcut.TargetPath = $targetPath
  $shortcut.WorkingDirectory = Split-Path -Path $targetPath -Parent
  $shortcut.IconLocation = "$targetPath, 0"
  $shortcut.Save()
}

$vsCodeZipURL = "https://update.code.visualstudio.com/$vsCodeVersion/win32-x64-archive/stable"
$vsCodeZipName = "VSCode-$vsCodeVersion-win32-x64-archive.zip"
$vsCodeZipDownloadPath = "C:\${vsCodeZipName}"
$vsCodeZipExtractPath = "C:\VSCode"
$defaultDesktopPath = "C:\Users\Default\Desktop"
$defaultStartMenuProgramsPath = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$vsCodeSettingsPath = "C:\Users\Default\AppData\Roaming\Code"

#Downloads installer
Write-Host "${scriptLogPrefix}: Downloading VSCode installer from $vsCodeZipURL to $vsCodeZipDownloadPath"
Invoke-WebRequest -Uri $vsCodeZipURL -OutFile $vsCodeZipDownloadPath

if (!(Test-Path $vsCodeZipDownloadPath)) {
  throw "VSCode installer was not found at $vsCodeZipDownloadPath after download"
}

#This extracts VS Code installation files
Write-Host "${scriptLogPrefix}: Extracting VSCode from $vsCodeZipDownloadPath to $vsCodeZipExtractPath"
Expand-Archive $vsCodeZipDownloadPath $vsCodeZipExtractPath | Out-Null

if (!(Test-Path "$vsCodeZipExtractPath\Code.exe")) {
  throw "VSCode executable was not found at $vsCodeZipExtractPath\Code.exe after extraction"
}

Write-Host "${scriptLogPrefix}: Extracted VSCode"

Write-Host "${scriptLogPrefix}: Ensuring VSCode data directory exists at C:\VSCode\data"
if (!(Test-Path "C:\VSCode\data")) {
  New-Item -Path "C:\VSCode\data" -ItemType Directory -Force | Out-Null
  Write-Host "${scriptLogPrefix}: Created VSCode data directory at C:\VSCode\data"
} else {
  Write-Host "${scriptLogPrefix}: VSCode data directory already exists at C:\VSCode\data"
}

# This configures VS Code, a.o. it disables recommendation pop-ups, it trusts external files automatically, a theme is set-up, and the welcome walkthrough is disabled
Write-Host "${scriptLogPrefix}: Copying over data folder to $vsCodeSettingsPath"
Copy-Item ".\files\vscode\User" $vsCodeSettingsPath -Force -Recurse | Out-Null

if (!(Test-Path "$vsCodeSettingsPath\User\settings.json")) {
  throw "VSCode user settings were not found at $vsCodeSettingsPath\User\settings.json after copying"
}

Write-Host "${scriptLogPrefix}: Successfully copied over data folder"

Write-Host "${scriptLogPrefix}: Creating Default user shortcuts"
New-Shortcut -shortcutPath (Join-Path $defaultDesktopPath "Visual Studio Code.lnk") -targetPath "$vsCodeZipExtractPath\Code.exe"
New-Shortcut -shortcutPath (Join-Path $defaultStartMenuProgramsPath "Visual Studio Code.lnk") -targetPath "$vsCodeZipExtractPath\Code.exe"
New-Shortcut -shortcutPath (Join-Path $defaultDesktopPath "File Explorer.lnk") -targetPath "C:\Windows\explorer.exe"
Write-Host "${scriptLogPrefix}: Done creating Default user shortcuts"

#This removes the installer
if ($RemoveInstaller) {
  Write-Host "${scriptLogPrefix}: Removing downloaded installer"
  Remove-Item $vsCodeZipDownloadPath | Out-Null
  Write-Host "${scriptLogPrefix}: Successfully removed $vsCodeZipDownloadPath"
}
