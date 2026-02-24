Param (
  [Parameter(Mandatory)]
  [string]$a_windowsLanguage,

  # Controls whether the extra Office login prompt fix should run
  [Parameter()]
  [ValidateSet("yes", "no")]
  [string]$c_removeExtraOfficeLogin,

  [Parameter(ValueFromRemainingArguments)]
  [string[]]$RemainingArgs                    # To make sure this script doesn't break when new parameters are added
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

if ($c_removeExtraOfficeLogin -eq "no") {
  Write-Host "=== Skipping extra Office login screen fix because c_removeExtraOfficeLogin=no ==="
}
else {
  Write-Host "=== Remove extra login screen for Office ==="
  & .\install_scripts\remove_extra_login_office.ps1
  Write-Host "=== Done with removing extra login screen for Office ==="
}

