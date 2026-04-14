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

# Warm VS Code once per user so the first interactive launch during the exam is faster.
$vsCodePath = "C:\VSCode\Code.exe"
$firstLoginRegistryPath = "HKCU:\Software\Schoolyear\FirstLoginActions"
$vsCodeWarmupRegistryName = "nl.tue.python.vscodeWarmup"
$vsCodeWarmed = Get-ItemPropertyValue -Path $firstLoginRegistryPath -Name $vsCodeWarmupRegistryName -ErrorAction SilentlyContinue

if ($vsCodeWarmed -ne 1) {
    if (-not (Test-Path -LiteralPath $vsCodePath)) {
        Write-Output "VS Code warm-up skipped because $vsCodePath was not found."
    } else {
        try {
            Write-Output "First login detected. Warming up VS Code."

            $existingCodeProcessIds = @(
                Get-Process -Name "Code" -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty Id
            )

            Start-Process -FilePath $vsCodePath -ArgumentList "--new-window" | Out-Null

            $visibleCodeProcesses = @()
            for ($i = 0; $i -lt 60 -and $visibleCodeProcesses.Count -eq 0; $i++) {
                Start-Sleep -Seconds 1
                $newCodeProcesses = @(
                    Get-Process -Name "Code" -ErrorAction SilentlyContinue |
                    Where-Object { $_.Id -notin $existingCodeProcessIds }
                )
                $visibleCodeProcesses = @(
                    $newCodeProcesses |
                    Where-Object { $_.MainWindowHandle -ne 0 }
                )
            }

            if ($visibleCodeProcesses.Count -eq 0) {
                if ($newCodeProcesses.Count -gt 0) {
                    $newCodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
                }

                Write-Output "VS Code warm-up skipped because no visible VS Code window appeared."
            } else {
                Start-Sleep -Seconds 20
                $newCodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue

                if (-not (Test-Path -LiteralPath $firstLoginRegistryPath)) {
                    New-Item -Path $firstLoginRegistryPath -Force | Out-Null
                }

                New-ItemProperty `
                    -Path $firstLoginRegistryPath `
                    -Name $vsCodeWarmupRegistryName `
                    -Value 1 `
                    -PropertyType DWord `
                    -Force | Out-Null

                Write-Output "VS Code warm-up completed."
            }
        } catch {
            Write-Warning "VS Code warm-up failed: $($_.Exception.Message)"
        }
    }
}
