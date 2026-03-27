# This script is executed every time a user logs into the VM which may be more than once
# Keep in mind that the student is waiting in the exam session for this script to finish
# You should not do any long running actions
#
# This script is executed as the user logging in, typically without admin rights

Param (
    [Parameter(Mandatory = $true)]
    [string]$uid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$gid,          # SID of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$username,     # Username of the Windows user logging in

    [Parameter(Mandatory = $true)]
    [string]$homedir,      # Absolute path to the user's home directory

    # To make sure this script doesn't break when new parameters are added
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Create VSCode icon in taskbar and on Desktop
$targetPath = "C:\VSCode\code.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutName = "Visual Studio Code.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$shortcutName"
$toolsDir = "C:\Tools"
$pttbPath = Join-Path $toolsDir "pttb.exe"
# Create shortcut on Desktop
$WScriptShell = New-Object -ComObject WScript.Shell
$desktopShortcut = $WScriptShell.CreateShortcut($shortcutPath)
$desktopShortcut.TargetPath = $targetPath
$desktopShortcut.WorkingDirectory = Split-Path $targetPath
$desktopShortcut.IconLocation = "$targetPath, 0"
$desktopShortcut.Save()
# Copy shortcut to Start menu
Copy-Item -Path $shortcutPath -Destination $startMenuPath -Force
# Pin icon to taskbar using pttb.exe
Start-Process -FilePath $pttbPath -ArgumentList "`"$targetPath`"" -Wait

# Create Windows Explorer icon in taskbar and on desktop
$targetPath = "C:\Windows\explorer.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutName = "File Explorer.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$shortcutName"
$toolsDir = "C:\Tools"
$pttbPath = Join-Path $toolsDir "pttb.exe"
# Create File Explorer shortcut on Desktop
$WScriptShell = New-Object -ComObject WScript.Shell
$desktopShortcut = $WScriptShell.CreateShortcut($shortcutPath)
$desktopShortcut.TargetPath = $targetPath
$desktopShortcut.WorkingDirectory = Split-Path $targetPath
$desktopShortcut.IconLocation = "$targetPath, 0"
$desktopShortcut.Save()
# Adds shortcut to Start menu
Copy-Item -Path $shortcutPath -Destination $startMenuPath -Force
# Pin to taskbar using pttb.exe
Start-Process -FilePath $pttbPath -ArgumentList "`"$targetPath`"" -Wait

# The main purpose of this part of the script is to set up Python in order to use the SY Trusted Proxy.
# Which in turn is configured to whitelist the hosts specified in our properties.json5 file.
# Configuring Python to use a proxy is as simple as creating a `pip.ini` file which is read by
# Python on startup.
# If you do NOT want to allow for the installation of external Python packages you can remove this file
# from the final build
# Within the VM SessionHosts Azure provides a `Metadata` service which contains (among others)
# the ip address of the SY proxy server which we can use to configure pip.
$url = "http://169.254.169.254/metadata/instance/compute/tagsList?api-version=2021-02-01"
$headers = @{
  "Metadata" = "true"
}
try {
  # Make the request and get the response
  $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
}
catch {
  Write-Error "Could not make request to metadata endpoint: $_"
  exit 1
}
# Find the "name": "proxyVmIpAddr" and print its value
$found = $false 
$proxyIpAddr = ""
foreach ($tag in $response) {
  if ($tag.name -eq "proxyVmIpAddr") {
    $proxyIpAddr = $tag.value
    $found = $true
    break
  }
}
if (!$found) {
  Write-Error "Could not find proxyVmIpAddr in metadata"
  exit 1
}
Write-Host "Found proxyIpAddr: $proxyIpAddr"
# Find user home directory and create a subfoler named 'pip'
# inside the `pip` subfolder we create the `pip.ini` file
$userHomeDir = [System.Environment]::GetFolderPath('UserProfile')
$pipDir = Join-Path -Path $userHomeDir -ChildPath "pip"
if (!(Test-Path $pipDir)) {
  Write-Host "Creating $pipDir"
  New-Item -Path $pipDir -ItemType Directory -Force | Out-Null
}
# and fill it with our trusted hosts
# and the proxy pip should use when downloading packages
$pipIniPath = Join-Path -Path $pipDir -ChildPath "pip.ini"
$pipIniContent = @"
[global]
trusted-host =  pypi.python.org
                pypi.org
                files.pythonhosted.org
proxy = http://$proxyIpAddr
"@
Write-Host "Writing pip.ini file at: $pipIniPath"
Set-Content -Path $pipIniPath -Value $pipIniContent
Write-Host "Wrote $pipIniPath"

#This part of the script add a folder to the path variable, this ensures additional installed packages can be used using a path variable
$folderToAdd = "$env:USERPROFILE\AppData\Roaming\Python\Python313\Scripts"
# Get the current user PATH environment variable
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
# Check if the folder is already in the PATH
if ($currentPath -notmatch [regex]::Escape($folderToAdd)) {
    # Add the folder to the PATH
    $newPath = "$currentPath;$folderToAdd"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Output "Folder added to user PATH successfully."
} else {
    Write-Output "Folder is already in the user PATH."
}

#start VSCode to make sure all extentions are loaded and ready for use.
Start-Process -FilePath C:\VSCode\Code.exe
Start-Sleep 10
Stop-Process -Name 'Code'

