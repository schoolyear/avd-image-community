Param (
    [Parameter(Mandatory = $true)]
    [string]$rVersion,

    [Parameter(Mandatory = $true)]
    [string]$rStudioVersion
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

Write-Host "=== Install R and R-Studio ==="
& .\install_scripts\r_and_rstudio_installation.ps1 -rVersion $rVersion -rStudioVersion $rStudioVersion
Write-Host "=== Done with R and R-Studio installation ==="

Write-Host "=== Post installation ==="
& .\install_scripts\rstudio_post_installation.ps1 -rVersion $rVersion
Write-Host "=== Done with post installation ==="

Write-Host "=== File association ==="
& .\install_scripts\file_associations.ps1
Write-Host "=== Done with file association ==="

Write-Host "=== Configure taskbar layout ==="
& .\install_scripts\configure_taskbar_layout.ps1
Write-Host "=== Done with taskbar layout ==="
