Param (
  [Parameter(Mandatory = $true)]
  [string]$pythonVersion
)

$ProgressPreference = 'SilentlyContinue'

$scriptLogPrefix = "Python"

Write-Host "${scriptLogPrefix}: Starting Python installation"

$pythonInstallerName = "python-$pythonVersion-amd64.exe"
$pythonInstallerURL = "https://www.python.org/ftp/python/$pythonVersion/$pythonInstallerName"
$pythonInstallerDownloadPath = "C:\${pythonInstallerName}"

#Downloads Python

Write-Host "${scriptLogPrefix}: Downloading Python installer from $pythonInstallerURL to $pythonInstallerDownloadPath"
Invoke-WebRequest -Uri $pythonInstallerURL -OutFile $pythonInstallerDownloadPath

if (!(Test-Path $pythonInstallerDownloadPath)) {
  throw "Python installer was not found at $pythonInstallerDownloadPath after download"
}

# Installs Python
Write-Host "${scriptLogPrefix}: Installing Python"
$process = Start-Process -FilePath $pythonInstallerDownloadPath -Args "/quiet InstallAllUsers=1 AssociateFiles=1 PrependPath=1" -Wait -NoNewWindow -PassThru
Write-Host "${scriptLogPrefix}: Process exit code: $($process.ExitCode)"
if ($process.ExitCode -ne 0) {
  throw "Python installation failed with exit code: $($process.ExitCode)"
}

Write-Host "${scriptLogPrefix}: Successfully installed Python"
