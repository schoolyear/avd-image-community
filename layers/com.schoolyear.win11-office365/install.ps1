# <CAN BE REMOVED>
# This script is executed during the preparation of the exam image
# This script is executed before the sysprep step
#
# This script is executed in its own layer folder
# So, any file in this image layer, is available in the current working directory
#
# Once all installation scripts are executed, all image layer files are deleted
# If you want to persist a file in the image, you must copy it to another folder
# </CAN BE REMOVED>

Param (
    # You can configure your own paramter in the properties.json5 file
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

$Hive = "HKU\DefaultUser"
$Dat  = "C:\Users\Default\NTUSER.DAT"

function Test-HiveLoaded([string]$HiveName) {
    & $env:ComSpec /c "reg.exe query `"$HiveName`" >nul 2>nul"
    return ($LASTEXITCODE -eq 0)
}

Write-Host "[DefaultUserHive] Loading hive from $Dat ..."
& reg.exe load $Hive $Dat
if ($LASTEXITCODE -ne 0) {
    throw "[DefaultUserHive] reg load failed with exit code $LASTEXITCODE"
}

try {
    Write-Host "[DefaultUserHive] Setting Office privacy registry value..."
    & reg.exe add "HKU\DefaultUser\Software\Microsoft\Office\16.0\Common" `
        /v PrivacyDialogsDisabled `
        /t REG_DWORD `
        /d 1 `
        /f
    if ($LASTEXITCODE -ne 0) {
        throw "[DefaultUserHive] reg add failed with exit code $LASTEXITCODE"
    }

    Write-Host "[DefaultUserHive] Registry value set."
}
finally {
    Write-Host "[DefaultUserHive] Unloading hive (strict mode)..."

    $TimeoutSeconds = 20

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "reg.exe"
    $psi.Arguments = "unload $Hive"
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    $null = $p.Start()

    if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
        Write-Host "[DefaultUserHive] Unload timed out. Killing reg.exe (PID $($p.Id))..."
        try { $p.Kill() } catch { }
        try { $p.WaitForExit() } catch { }
        throw "[DefaultUserHive] Unload timed out after ${TimeoutSeconds}s."
    }

    $stdout = $p.StandardOutput.ReadToEnd().Trim()
    $stderr = $p.StandardError.ReadToEnd().Trim()

    if ($stdout) { Write-Host "[DefaultUserHive] reg.exe stdout: $stdout" }
    if ($stderr) { Write-Host "[DefaultUserHive] reg.exe stderr: $stderr" }

    if ($p.ExitCode -ne 0) {
        throw "[DefaultUserHive] reg unload failed (ExitCode=$($p.ExitCode))."
    }

    # Explicit verification
    if (Test-HiveLoaded $Hive) {
        throw "[DefaultUserHive] Hive still mounted after unload attempt."
    }

    Write-Host "[DefaultUserHive] Unload confirmed successful."
}

Write-Host "[DefaultUserHive] Completed successfully."


