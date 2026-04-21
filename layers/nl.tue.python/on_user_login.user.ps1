# This script is executed every time a user logs into the VM which may be more than once
# Keep in mind that the student is waiting in the exam session for this script to finish
# You should not do any long running actions
#
# This script is executed as the user logging in, typically without admin rights.
# It keeps the per-user PATH aligned with the Python user base so installed scripts are available.

Param (
    [Parameter(Mandatory = $true)]
    [string]$uid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$gid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$username,     # Username of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$homedir,      # Absolute path to the user's home directory

    # To make sure this script doesn't break when new parameters are added
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Add the Python user Scripts directory to the user PATH so commands from user-installed packages are available.
$folderToAdd = (& python -c "import os, sysconfig; print(sysconfig.get_path('scripts', scheme=f'{os.name}_user'))").Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Failed to determine the Python user Scripts directory"
}

# Get the current user PATH environment variable
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

# Check if the folder is already in the PATH
if ($currentPath -notmatch [regex]::Escape($folderToAdd)) {
    # Add the folder to the PATH
    $newPath = "$currentPath;$folderToAdd"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Output "Folder added to user PATH successfully."
} else {
    Write-Output "Folder is already in the user PATH."
}
