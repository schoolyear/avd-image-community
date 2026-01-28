# This script is executed every time a user logs into the VM which may be more than once
# Keep in mind that the student is waiting in the exam session for this script to finish
# You should not do any long running actions
#
# This script is executed as a priviledged user, not the user logging in

Param (
    [Parameter(Mandatory = $true)]
    [string]$uid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$gid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$username,     # Username of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$homedir,       # Absolute path to the user's home directory

    # To make sure this script doesn't break when new parameters are added
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
    $desktop = Join-Path -Path $homedir -ChildPath "Desktop"
    if (-not (Test-Path -LiteralPath $desktop)) {
        New-Item -ItemType Directory -Path $desktop -Force | Out-Null
    }

    $stamp   = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $logPath = Join-Path -Path $desktop -ChildPath ("culture-log_{0}.txt" -f $stamp)

    $culture = Get-Culture

    @(
        "Timestamp : $(Get-Date -Format o)"
        "Username  : $username"
        "UID (SID) : $uid"
        "HomeDir   : $homedir"
        "Culture   : $($culture.Name)"
        "Display   : $($culture.DisplayName)"
        "IetfTag   : $($culture.IetfLanguageTag)"
        "English   : $($culture.EnglishName)"
    ) | Set-Content -LiteralPath $logPath -Encoding UTF8

} catch {
    # Keep this lightweight; do not block the student for long.
    Write-Host "*** Failed to write culture log to Desktop: $($_.Exception.Message)"
}

Set-Culture nl-NL