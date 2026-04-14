Param (
  [Parameter(Mandatory = $true)]
  [string]$pythonVersion
)

$scriptName = Split-Path -Path $PSCommandPath -Leaf
$scriptLogPrefix = "Python file association"

$pythonInstallDirectoryName = "Python$($pythonVersion.Split('.')[0])$($pythonVersion.Split('.')[1])"
$pythonInstallDirectory = Join-Path -Path $env:ProgramFiles -ChildPath $pythonInstallDirectoryName
$vsCodeIconSourcePath = ".\resources\vscode\vscode.ico"
$vsCodeIconDestinationPath = Join-Path -Path $pythonInstallDirectory -ChildPath "vscode.ico"
$registryKey = "registry::HKEY_CLASSES_ROOT"
$vsCodeExecutable = "C:\VSCode\Code.exe"

# Copy the VS Code icon used for Python file associations.
Write-Host "${scriptLogPrefix}: Copying VSCode icon from $vsCodeIconSourcePath to $vsCodeIconDestinationPath"
Copy-Item $vsCodeIconSourcePath $vsCodeIconDestinationPath -Force | Out-Null

if (!(Test-Path $vsCodeIconDestinationPath)) {
  throw "VSCode icon was not found at $vsCodeIconDestinationPath after copying"
}

# Set up Python file associations that open in VS Code.
Write-Host "${scriptLogPrefix}: Setting up file associations for Python"
New-Item -Path "$registryKey\.py" -Force | Out-Null
New-Item -Path "$registryKey\.python" -Force | Out-Null
New-Item -Path "$registryKey\.pyc" -Force | Out-Null
New-Item -Path "$registryKey\.pyd" -Force | Out-Null
New-Item -Path "$registryKey\.pyo" -Force | Out-Null
New-Item -Path "$registryKey\.pyw" -Force | Out-Null
New-Item -Path "$registryKey\.pyz" -Force | Out-Null
New-Item -Path "$registryKey\.pyzw" -Force | Out-Null
New-Item -Path "$registryKey\.ipynb" -Force | Out-Null
New-ItemProperty -Path "$registryKey\.py" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.python" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyc" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyd" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyo" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyw" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyz" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.pyzw" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "$registryKey\.ipynb" -Name "(Default)" -Value "Python.File" -PropertyType String -Force | Out-Null
New-Item -Path "$registryKey\Python.File" -Force | Out-Null
New-ItemProperty -Path "$registryKey\Python.File" -Name "(Default)" -Value "Python File" -PropertyType String -Force | Out-Null
New-Item -Path "$registryKey\Python.File\shell\open\command" -Force | Out-Null
New-ItemProperty -Path "$registryKey\Python.File\shell\open\command" -Name "(Default)" -Value "$vsCodeExecutable `"%1`"" -PropertyType String -Force | Out-Null
New-Item -Path "$registryKey\Python.File\DefaultIcon" -Force | Out-Null
New-ItemProperty -Path "$registryKey\Python.File\DefaultIcon" -Name "(Default)" -Value "$vsCodeIconDestinationPath,0" -PropertyType String -Force | Out-Null
Write-Host "${scriptLogPrefix}: Done setting up file associations for Python"
