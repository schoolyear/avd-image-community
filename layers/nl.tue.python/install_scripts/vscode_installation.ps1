param (
  [Parameter(Mandatory = $true)]
  [string]$vsCodeVersion,

  [switch]$RemoveInstaller
)

$ProgressPreference = 'SilentlyContinue'

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

function Copy-Shortcut {
  param (
    [Parameter(Mandatory = $true)]
    [string]$sourcePath,

    [Parameter(Mandatory = $true)]
    [string]$shortcutPath
  )

  if (!(Test-Path -LiteralPath $sourcePath)) {
    throw "Shortcut source was not found at $sourcePath"
  }

  $shortcutDirectory = Split-Path -Path $shortcutPath -Parent
  if (!(Test-Path $shortcutDirectory)) {
    New-Item -Path $shortcutDirectory -ItemType Directory -Force | Out-Null
  }

  Copy-Item -LiteralPath $sourcePath -Destination $shortcutPath -Force | Out-Null

  if (!(Test-Path -LiteralPath $shortcutPath)) {
    throw "Shortcut was not found at $shortcutPath after copying"
  }
}

$vsCodeZipURL = "https://update.code.visualstudio.com/$vsCodeVersion/win32-x64-archive/stable"
$vsCodeZipName = "VSCode-$vsCodeVersion-win32-x64-archive.zip"
$vsCodeZipDownloadPath = "C:\${vsCodeZipName}"
$vsCodeZipExtractPath = "C:\VSCode"
$vsCodeDataPath = Join-Path $vsCodeZipExtractPath "data"
$vsCodeShortcutSourcePath = ".\resources\vscode\Visual Studio Code.lnk"
$defaultDesktopPath = "C:\Users\Default\Desktop"
$defaultStartMenuProgramsPath = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$allUsersStartMenuProgramsPath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs"
$vsCodeSettingsPath = Join-Path $vsCodeDataPath "user-data"

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

Write-Host "${scriptLogPrefix}: Ensuring VSCode portable data directory exists at $vsCodeDataPath"
if (!(Test-Path $vsCodeDataPath)) {
  New-Item -Path $vsCodeDataPath -ItemType Directory -Force | Out-Null
  Write-Host "${scriptLogPrefix}: Created VSCode portable data directory at $vsCodeDataPath"
} else {
  Write-Host "${scriptLogPrefix}: VSCode portable data directory already exists at $vsCodeDataPath"
}

# This configures VS Code portable mode
Write-Host "${scriptLogPrefix}: Ensuring VSCode portable user-data directory exists at $vsCodeSettingsPath"
if (!(Test-Path $vsCodeSettingsPath)) {
  New-Item -Path $vsCodeSettingsPath -ItemType Directory -Force | Out-Null
  Write-Host "${scriptLogPrefix}: Created VSCode portable user-data directory at $vsCodeSettingsPath"
} else {
  Write-Host "${scriptLogPrefix}: VSCode portable user-data directory already exists at $vsCodeSettingsPath"
}

# This configures VS code settings, a.o. it disables recommendation pop-ups,
# trusts external files automatically, sets a theme, and disables the welcome walkthrough.
Write-Host "${scriptLogPrefix}: Copying VSCode portable user data to $vsCodeSettingsPath"
Copy-Item ".\resources\vscode\portable-user-data\*" $vsCodeSettingsPath -Force -Recurse | Out-Null

if (!(Test-Path "$vsCodeSettingsPath\User\settings.json")) {
  throw "VSCode user settings were not found at $vsCodeSettingsPath\User\settings.json after copying"
}

Write-Host "${scriptLogPrefix}: Successfully copied VSCode portable user data"

# This creates shortcuts
Write-Host "${scriptLogPrefix}: Creating Default user shortcuts"
Copy-Shortcut -sourcePath $vsCodeShortcutSourcePath -shortcutPath (Join-Path $defaultDesktopPath "Visual Studio Code.lnk")
Copy-Shortcut -sourcePath $vsCodeShortcutSourcePath -shortcutPath (Join-Path $defaultStartMenuProgramsPath "Visual Studio Code.lnk")
New-Shortcut -shortcutPath (Join-Path $defaultDesktopPath "File Explorer.lnk") -targetPath "C:\Windows\explorer.exe"
Write-Host "${scriptLogPrefix}: Done creating Default user shortcuts"

Write-Host "${scriptLogPrefix}: Creating all-users Start Menu shortcut"
Copy-Shortcut -sourcePath $vsCodeShortcutSourcePath -shortcutPath (Join-Path $allUsersStartMenuProgramsPath "Visual Studio Code.lnk")
Write-Host "${scriptLogPrefix}: Done creating all-users Start Menu shortcut"

#This removes the installer
if ($RemoveInstaller) {
  Write-Host "${scriptLogPrefix}: Removing downloaded installer"
  Remove-Item $vsCodeZipDownloadPath | Out-Null
  Write-Host "${scriptLogPrefix}: Successfully removed $vsCodeZipDownloadPath"
}
