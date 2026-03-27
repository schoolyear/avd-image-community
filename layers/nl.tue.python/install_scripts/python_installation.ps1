$scriptName = Split-Path -Path $PSCommandPath -Leaf

Write-Host "Start Script, Python installation"

$pythonInstallerName = "python-3.13.3-amd64.exe"
$pythonInstallerURL = "https://www.python.org/ftp/python/3.13.3/python-3.13.3-amd64.exe"
$pythonInstallerDownloadPath = "C:\${pythonInstallerName}"

#Downloads Python
if (!(Test-Path $pythonInstallerDownloadPath)) {
  Write-Host "Python Installer not found, downloading..."
  $output = Invoke-WebRequest -Uri $pythonInstallerURL -OutFile $pythonInstallerDownloadPath 2>&1
  Write-Host $output
}


# Installs Python
try {
  Write-Host "Installing python..."
  $process = Start-Process -FilePath $pythonInstallerDownloadPath -Args "/quiet InstallAllUsers=1 AssociateFiles=1 PrependPath=1" -Wait -NoNewWindow -PassThru
  Write-Host "Process exit code: $($process.ExitCode)"
  if ($process.ExitCode -eq 0) {
    Write-Host "Successfully installed python"
  } else {
    Write-Host "Python installation failed with exit code: $($process.ExitCode)"
  }
} catch {
  Write-Host "Failed to install python: $_"
}
