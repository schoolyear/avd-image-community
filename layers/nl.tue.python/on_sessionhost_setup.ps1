# This script is executed on each sessionhost during deployment
# Note that any time spent in this script adds to the deployment time of each VM (and thus the deployment time of exams)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Block inbound traffic for VS Code to suppress the Windows Firewall prompt on first run.
$firewallRuleName = "nl.tue.python.vscode.block-inbound"

if (-not (Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule `
    -Name $firewallRuleName `
    -DisplayName "TUE Python layer - Block inbound Visual Studio Code" `
    -Direction Inbound `
    -Action Block `
    -Program "C:\VSCode\Code.exe" `
    -Profile Any | Out-Null
}
