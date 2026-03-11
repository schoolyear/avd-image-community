Param (
  [Parameter(Mandatory)]
  [string]$windowsDisplayLanguage,

  # Controls whether the extra Office login prompt fix should run
  [Parameter()]
  [ValidateSet("yes", "no")]
  [string]$removeExtraOfficeLoginPrompt,

  [Parameter(ValueFromRemainingArguments)]
  [string[]]$RemainingArgs                    # To make sure this script doesn't break when new parameters are added
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$scriptLogPrefix = "Language support install"

if ($removeExtraOfficeLoginPrompt -eq "no") {
  Write-Host "${scriptLogPrefix}: Skipping extra Office login screen fix because removeExtraOfficeLoginPrompt=no"
}
else {
  Write-Host "${scriptLogPrefix}: Removing extra login screen for Office"
  & .\install_scripts\remove_extra_login_office.ps1
  Write-Host "${scriptLogPrefix}: Done removing extra login screen for Office"
}

