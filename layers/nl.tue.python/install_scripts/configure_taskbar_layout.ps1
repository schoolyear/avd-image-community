Param ()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptLogPrefix = "Taskbar layout"

$vsCodeShortcutPath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\Visual Studio Code.lnk"
$layoutSourcePath = ".\resources\taskbar\TaskbarLayoutModification.xml"
$layoutDirectory = "C:\Windows\OEM"
$layoutDestinationPath = Join-Path $layoutDirectory "TaskbarLayoutModification.xml"
$explorerRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$layoutRegistryName = "LayoutXMLPath"

if (!(Test-Path $vsCodeShortcutPath)) {
  throw "VS Code Start Menu shortcut was not found at $vsCodeShortcutPath"
}

if (!(Test-Path $layoutSourcePath)) {
  throw "Taskbar layout resource was not found at $layoutSourcePath"
}

if (!(Test-Path $layoutDirectory)) {
  Write-Host "${scriptLogPrefix}: Creating $layoutDirectory"
  New-Item -Path $layoutDirectory -ItemType Directory -Force | Out-Null
}

Write-Host "${scriptLogPrefix}: Copying taskbar layout to $layoutDestinationPath"
Copy-Item -Path $layoutSourcePath -Destination $layoutDestinationPath -Force | Out-Null

if (!(Test-Path $layoutDestinationPath)) {
  throw "Taskbar layout file was not found at $layoutDestinationPath after copying"
}

Write-Host "${scriptLogPrefix}: Setting HKLM taskbar layout path"
if (!(Test-Path $explorerRegistryPath)) {
  throw "Explorer registry path was not found at $explorerRegistryPath"
}

New-ItemProperty `
  -Path $explorerRegistryPath `
  -Name $layoutRegistryName `
  -Value $layoutDestinationPath `
  -PropertyType String `
  -Force | Out-Null

$configuredLayoutPath = Get-ItemPropertyValue -Path $explorerRegistryPath -Name $layoutRegistryName
if ($configuredLayoutPath -ne $layoutDestinationPath) {
  throw "Taskbar layout registry path was not set correctly. Expected $layoutDestinationPath, got $configuredLayoutPath"
}

Write-Host "${scriptLogPrefix}: Configured default taskbar layout"
