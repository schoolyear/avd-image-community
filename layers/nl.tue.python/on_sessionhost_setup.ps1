# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

#The line below disables the "Windows firewall has blockes some features of this app" pop-up as it pops up when running code the first time, because VSCode tries to access the internet.
New-NetFirewallRule `
  -Name "nl.tue.python.vscode.block-inbound" `
  -DisplayName "TUE Python layer - Block inbound Visual Studio Code" `
  -Direction Inbound `
  -Action Block `
  -Program "C:\VSCode\Code.exe" `
  -Profile Any | Out-Null
