$pipExecutable = "C:\Program Files\Python313\Scripts\pip.exe"
$scriptLogPrefix = "Python post-installation"

Write-Host "${scriptLogPrefix}: Installing packages one by one"

$packages = @(
#  "pandas",
#  "vpython",
  "ipykernel"
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
