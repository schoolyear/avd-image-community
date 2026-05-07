Param (
  [Parameter(Mandatory = $true)]
  [string]$pythonVersion
)

$pythonInstallDirectoryName = "Python$($pythonVersion.Split('.')[0])$($pythonVersion.Split('.')[1])"
$pythonInstallDirectory = Join-Path -Path $env:ProgramFiles -ChildPath $pythonInstallDirectoryName
$pipExecutable = Join-Path -Path $pythonInstallDirectory -ChildPath "Scripts\pip.exe"
$scriptLogPrefix = "Python post-installation"

if (!(Test-Path $pipExecutable)) {
  throw "pip executable was not found at $pipExecutable"
}

Write-Host "${scriptLogPrefix}: Installing packages one by one"

$packages = @(
# Uncomment to install additional packages.
#  "pandas",
#  "vpython",
#  "ipykernel"
#  "numpy",
#  "matplotlib",
#  "requests",
#  "flask",
#  "django"
)

foreach ($package in $packages) {
  Write-Host "${scriptLogPrefix}: Installing package $package"

  $process = Start-Process -FilePath $pipExecutable -ArgumentList "install", $package -Wait -NoNewWindow -PassThru
  Write-Host "${scriptLogPrefix}: Process exit code: $($process.ExitCode)"

  if ($process.ExitCode -ne 0) {
    throw "Failed to install package: $package. Exit code: $($process.ExitCode)"
  }

  Write-Host "${scriptLogPrefix}: Successfully installed $package"
}

Write-Host "${scriptLogPrefix}: Done installing packages"
