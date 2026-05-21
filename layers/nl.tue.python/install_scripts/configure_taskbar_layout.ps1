$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptLogPrefix = "Taskbar layout"

$vsCodeShortcutPath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\Visual Studio Code.lnk"
$vsCodeShortcutLayoutPath = "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Visual Studio Code.lnk"
$layoutSourcePath = ".\resources\taskbar\TaskbarLayoutModification.xml"
$layoutDirectory = "C:\Windows\OEM"
$layoutDestinationPath = Join-Path $layoutDirectory "TaskbarLayoutModification.xml"
$explorerRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$layoutRegistryName = "LayoutXMLPath"

function Add-VSCodeTaskbarPin {
  param (
    [Parameter(Mandatory = $true)]
    [string]$LayoutPath,

    [Parameter(Mandatory = $true)]
    [string]$DesktopApplicationLinkPath
  )

  # Load the existing taskbar layout XML so we can append the VS Code pin entry.
  [xml]$layoutXml = Get-Content -LiteralPath $LayoutPath

  $layoutNamespaceUri = "http://schemas.microsoft.com/Start/2014/LayoutModification"
  $defaultLayoutNamespaceUri = "http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
  $taskbarNamespaceUri = "http://schemas.microsoft.com/Start/2014/TaskbarLayout"

  $namespaceManager = New-Object System.Xml.XmlNamespaceManager($layoutXml.NameTable)
  $namespaceManager.AddNamespace("layout", $layoutNamespaceUri)
  $namespaceManager.AddNamespace("defaultlayout", $defaultLayoutNamespaceUri)
  $namespaceManager.AddNamespace("taskbar", $taskbarNamespaceUri)

  $pinList = $layoutXml.SelectSingleNode("//taskbar:TaskbarPinList", $namespaceManager)

  if ($null -eq $pinList) {
    # Some layouts do not define a pin list yet, so create the missing XML structure first.
    $customTaskbarLayoutCollection = $layoutXml.SelectSingleNode("//layout:CustomTaskbarLayoutCollection", $namespaceManager)
    if ($null -eq $customTaskbarLayoutCollection) {
      throw "CustomTaskbarLayoutCollection was not found in $LayoutPath"
    }

    $taskbarLayout = $layoutXml.SelectSingleNode("//defaultlayout:TaskbarLayout", $namespaceManager)
    if ($null -eq $taskbarLayout) {
      $taskbarLayout = $layoutXml.CreateElement("defaultlayout", "TaskbarLayout", $defaultLayoutNamespaceUri)
      $customTaskbarLayoutCollection.AppendChild($taskbarLayout)
    }

    $pinList = $layoutXml.CreateElement("taskbar", "TaskbarPinList", $taskbarNamespaceUri)
    $taskbarLayout.AppendChild($pinList)
  }

  # Add VS Code as a desktop app pin and save the updated layout back to disk.
  $desktopApp = $layoutXml.CreateElement("taskbar", "DesktopApp", $taskbarNamespaceUri)
  $desktopApp.SetAttribute("DesktopApplicationLinkPath", $DesktopApplicationLinkPath)
  $pinList.AppendChild($desktopApp)

  $layoutXml.Save($LayoutPath)
  Write-Host "${scriptLogPrefix}: Added VS Code taskbar pin to $LayoutPath"
}

if (!(Test-Path $vsCodeShortcutPath)) {
  throw "VS Code Start Menu shortcut was not found at $vsCodeShortcutPath"
}

if (!(Test-Path $layoutDirectory)) {
  Write-Host "${scriptLogPrefix}: Creating $layoutDirectory"
  New-Item -Path $layoutDirectory -ItemType Directory -Force | Out-Null
}

if (Test-Path $layoutDestinationPath) {
  # Reuse the existing OEM layout file and append the VS Code pin if the file is already present.
  Write-Host "${scriptLogPrefix}: Updating existing taskbar layout at $layoutDestinationPath"
  Add-VSCodeTaskbarPin -LayoutPath $layoutDestinationPath -DesktopApplicationLinkPath $vsCodeShortcutLayoutPath
} else {
  if (!(Test-Path $layoutSourcePath)) {
    throw "Taskbar layout resource was not found at $layoutSourcePath"
  }

  # Copy the default taskbar layout file into the OEM folder the first time.
  Write-Host "${scriptLogPrefix}: Copying taskbar layout to $layoutDestinationPath"
  Copy-Item -Path $layoutSourcePath -Destination $layoutDestinationPath -Force | Out-Null
}

if (!(Test-Path $layoutDestinationPath)) {
  throw "Taskbar layout file was not found at $layoutDestinationPath after copying"
}

Write-Host "${scriptLogPrefix}: Setting HKLM taskbar layout path"
if (!(Test-Path $explorerRegistryPath)) {
  throw "Explorer registry path was not found at $explorerRegistryPath"
}

# Point Explorer at the OEM layout file so new profiles inherit the configured taskbar pins.
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
