$scriptName = Split-Path -Path $PSCommandPath -Leaf

$extensions = @(
  "ms-python.python",
  "ms-python.vscode-pylance",
  "ms-toolsai.jupyter",
  "ms-toolsai.vscode-jupyter-cell-tags",
  "ms-toolsai.jupyter-keymap",
  "ms-toolsai.jupyter-renderers",
  "ms-toolsai.vscode-jupyter-slideshow",
  "tankashing.blinds-theme"
)

$codeCommandLinePath = "C:\VSCode\bin\code.cmd"

#This installs some VS Code extensions, including a colour blindness theme
function Install-VSCodeExtension {
    param (
        [string]$Extension,
        [int]$Retries = 3
    )

    for ($i = 0; $i -lt $Retries; $i++) {
        try {
            Write-Host "Attempting to install extension: $Extension (try $($i + 1)/$Retries)"
            Start-Process -FilePath $codeCommandLinePath -ArgumentList "--install-extension", $Extension -Wait -NoNewWindow -ErrorAction Stop
            Write-Host "Successfully installed: $Extension"
            return
        } catch {
            if ($i -eq $Retries - 1) {
                Write-Host "Failed to install $Extension after $Retries attempts: $_"
            } else {
                Write-Host "Retrying $Extension due to error: $_"
                Start-Sleep -Seconds 5
            }
        }
    }
}

try {
    foreach ($extension in $extensions) {
        Install-VSCodeExtension -Extension $extension
    }
} catch {
    Write-Host "General failure during extension installation process: $_"
}

#Installing extensions creates some necesarry files in the User profile, since the System user installs these, the files need to be copied to the student user
Try {
    Copy-Item -Path "C:\Windows\System32\config\systemprofile\.vscode\extensions" -Destination "C:\users\Default\.vscode\extensions" -Recurse -Force
    }
    Catch {
        Write-Host "Failed to copy extensions to Default user due to error: $_"
    }
