$scriptName = Split-Path -Path $PSCommandPath -Leaf
$scriptLogPrefix = "VSCode extension"

$extensions = @(
  "ms-python.python",
  "ms-python.vscode-pylance",
  # Uncomment to install Jupyter extensions. Please note this will add time to student start-up.
  # "ms-toolsai.jupyter",
  # "ms-toolsai.vscode-jupyter-cell-tags",
  # "ms-toolsai.jupyter-keymap",
  # "ms-toolsai.jupyter-renderers",
  # "ms-toolsai.vscode-jupyter-slideshow",
  "tankashing.blinds-theme"
)

$codeCommandLinePath = "C:\VSCode\bin\code.cmd"
$vsCodePortableExtensionsPath = "C:\VSCode\data\extensions"

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

# In portable mode, extensions are stored in C:\VSCode\data\extensions instead of a user profile.
Write-Host "${scriptLogPrefix}: Verifying VSCode portable extensions at $vsCodePortableExtensionsPath"

if (!(Test-Path $vsCodePortableExtensionsPath)) {
    throw "VSCode extensions were not found at $vsCodePortableExtensionsPath after installation"
}

Write-Host "${scriptLogPrefix}: VSCode portable extensions are available at $vsCodePortableExtensionsPath"
