
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

## EXAMPLE: WHITELIST IP
## NOTE: Due to limitations in Azure, only TCP and UDP are supported
## NOTE: It is recommended to configure any IP address or port as a build parameter. These things tend to change **and** allows you to share your layers with others
#
# New-NetFirewallRule -DisplayName 'allow-ip' -Direction Outbound -Action Allow -RemoteAddress '1.2.3.4' -Protocol TCP -RemotePort 8080 -Profile Any -ErrorAction Stop

## EXAMPLE: WHITELIST HOSTNAME
## NOTE: Due to limitations in Azure, only TCP and UDP are supported
## NOTE: It is recommended to configure any IP address or port as a build parameter. These things tend to change **and** allows you to share your layers with others
## NOTE: Only use hostname whitelisting when you are sure no other resources are hosted on IP(s) to which this hostname resolves.
##       The actual IP addresses of this hostname will be whitelisted. Any resource hosted on these servers will be accessible to students. Not only the hostname you configure here
#
# New-NetFirewallDynamicKeywordAddress -Id "{any-unique-guid}" -Keyword "example.com" -AutoResolve $true
# New-NetFirewallRule -DisplayName "Allow All Outbound to example.com" -Direction Outbound -Action Allow -RemoteDynamicKeywordAddresses (Get-NetFirewallDynamicKeywordAddress -Keyword "example.com").ID

Write-Host "${scriptLogPrefix}: Installing Python"
& .\install_scripts\python_installation.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing Python"

Write-Host "${scriptLogPrefix}: Installing Python packages"
& .\install_scripts\python_post_installation.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing Python packages"

Write-Host "${scriptLogPrefix}: Installing VSCode"
& .\install_scripts\vscode_installation.ps1 -vsCodeVersion $vsCodeVersion -RemoveInstaller
Write-Host "${scriptLogPrefix}: Done installing VSCode"

Write-Host "${scriptLogPrefix}: Installing VSCode extensions"
& .\install_scripts\install_extensions_vscode.ps1
Write-Host "${scriptLogPrefix}: Done installing VSCode extensions"

Write-Host "${scriptLogPrefix}: Installing file associations and Python icon"
& .\install_scripts\file_associations_and_python_icon.ps1 -pythonVersion $pythonVersion
Write-Host "${scriptLogPrefix}: Done installing file associations and Python icon"
