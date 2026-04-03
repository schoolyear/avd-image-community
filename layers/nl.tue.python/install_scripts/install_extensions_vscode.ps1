$scriptName = Split-Path -Path $PSCommandPath -Leaf
$scriptLogPrefix = "VSCode extension"

$extensions = @(
  "ms-python.python@2026.5.2026032701",
  "ms-python.vscode-pylance@2026.2.1",
  "ms-toolsai.jupyter@2025.10.2026040301",
  "ms-toolsai.vscode-jupyter-cell-tags@0.1.9",
  "ms-toolsai.jupyter-keymap@1.1.2",
  "ms-toolsai.jupyter-renderers@1.3.2025062701",
  "ms-toolsai.vscode-jupyter-slideshow@0.1.6",
  "tankashing.blinds-theme@8.0.0"
)

$codeCommandLinePath = "C:\VSCode\bin\code.cmd"

#This installs some VS Code extensions, including a colour blindness theme
function Install-VSCodeExtension {
    param (
        [string]$Extension,
        [int]$Retries = 3
    )

    for ($i = 0; $i -lt $Retries; $i++) {
        Write-Host "${scriptLogPrefix}: Attempting to install extension: $Extension (try $($i + 1)/$Retries)"
        $process = Start-Process -FilePath $codeCommandLinePath -ArgumentList "--install-extension", $Extension -Wait -NoNewWindow -PassThru
        Write-Host "${scriptLogPrefix}: Process exit code: $($process.ExitCode)"

        if ($process.ExitCode -eq 0) {
            Write-Host "${scriptLogPrefix}: Successfully installed $Extension"
            return
        }

        if ($i -eq $Retries - 1) {
            throw "Failed to install $Extension after $Retries attempts. Last exit code: $($process.ExitCode)"
        }

        Write-Host "${scriptLogPrefix}: Retrying $Extension after exit code $($process.ExitCode)"
        Start-Sleep -Seconds 5
    }
}

if (!(Test-Path $codeCommandLinePath)) {
    throw "VSCode command line executable was not found at $codeCommandLinePath"
}

foreach ($extension in $extensions) {
    Install-VSCodeExtension -Extension $extension
}

#Installing extensions creates some necesarry files in the User profile, since the System user installs these, the files need to be copied to the student user
Write-Host "${scriptLogPrefix}: Copying VSCode extensions to C:\users\Default\.vscode\extensions"
Copy-Item -Path "C:\Windows\System32\config\systemprofile\.vscode\extensions" -Destination "C:\users\Default\.vscode\extensions" -Recurse -Force

if (!(Test-Path "C:\users\Default\.vscode\extensions")) {
    throw "VSCode extensions were not found at C:\users\Default\.vscode\extensions after copying"
}
