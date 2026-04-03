Param (
  [Parameter(Mandatory = $true)]
  [string]$pythonVersion
)

$scriptName = Split-Path -Path $PSCommandPath -Leaf

Write-Host "Start Script, Python installation"

$pythonInstallerName = "python-$pythonVersion-amd64.exe"
$pythonInstallerURL = "https://www.python.org/ftp/python/$pythonVersion/$pythonInstallerName"
$pythonInstallerDownloadPath = "C:\${pythonInstallerName}"

#Downloads Python

Write-Host "Downloading Python Installer from $pythonInstallerURL to $pythonInstallerDownloadPath"
Invoke-WebRequest -Uri $pythonInstallerURL -OutFile $pythonInstallerDownloadPath

if (!(Test-Path $pythonInstallerDownloadPath)) {
  throw "Python installer was not found at $pythonInstallerDownloadPath after download"
}

# Installs Python
Write-Host "Installing python..."
$process = Start-Process -FilePath $pythonInstallerDownloadPath -Args "/quiet InstallAllUsers=1 AssociateFiles=1 PrependPath=1" -Wait -NoNewWindow -PassThru
Write-Host "Process exit code: $($process.ExitCode)"
if ($process.ExitCode -ne 0) {
  throw "Python installation failed with exit code: $($process.ExitCode)"
}

Write-Host "Successfully installed python"
