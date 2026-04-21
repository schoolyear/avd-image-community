
Param (
    [Parameter(Mandatory = $true)]
    [string]$pythonVersion,

    [Parameter(Mandatory = $true)]
    [string]$vsCodeVersion,

    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs                    # To make sure this script doesn't break when new parameters are added
)

# Recommended snippet to make sure PowerShell stops execution on failure
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5#erroractionpreference
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.4
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Recommended snippet to make sure PowerShell doesn't show a progress bar when downloading files
# This makes the downloads considerably faster
$ProgressPreference = 'SilentlyContinue'
$scriptLogPrefix = "Python"

Write-Host "${scriptLogPrefix}: Installing Python"
& .\install_scripts\python_installation.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing Python"

Write-Host "${scriptLogPrefix}: Installing Python packages"
& .\install_scripts\python_post_installation.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing Python packages"

Write-Host "${scriptLogPrefix}: Configuring pip proxy"
& .\install_scripts\configure_pip_proxy.ps1
Write-Host "${scriptLogPrefix}: Done configuring pip proxy"

Write-Host "${scriptLogPrefix}: Installing VSCode"
& .\install_scripts\vscode_installation.ps1 -vsCodeVersion $vsCodeVersion -RemoveInstaller
Write-Host "${scriptLogPrefix}: Done installing VSCode"

Write-Host "${scriptLogPrefix}: Installing VSCode extensions"
& .\install_scripts\install_extensions_vscode.ps1
Write-Host "${scriptLogPrefix}: Done installing VSCode extensions"

Write-Host "${scriptLogPrefix}: Installing file associations and VSCode icon"
& .\install_scripts\file_associations_and_vscode_icon.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing file associations and VSCode icon"

Write-Host "${scriptLogPrefix}: Configuring taskbar layout"
& .\install_scripts\configure_taskbar_layout.ps1
Write-Host "${scriptLogPrefix}: Done configuring taskbar layout"
