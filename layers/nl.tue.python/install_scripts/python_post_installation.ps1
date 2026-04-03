$pipExecutable = "C:\Program Files\Python313\Scripts\pip.exe"

Write-Host "Installing packages one by one"

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
  Write-Host "Installing package: $package"

  $process = Start-Process -FilePath $pipExecutable -ArgumentList "install", $package -Wait -NoNewWindow -PassThru
  Write-Host "Process exit code: $($process.ExitCode)"

  if ($process.ExitCode -ne 0) {
    throw "Failed to install package: $package. Exit code: $($process.ExitCode)"
  }

  Write-Host "Successfully installed $package"
}

Write-Host "Done installing packages"
