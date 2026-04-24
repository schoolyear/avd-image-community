# Experimental: Opens and closes the start menu once, to ensure the start menu is responsive when a student first tries to open it.
# Adds ~10 seconds to initial start-up.
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

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$firstLoginRegistryPath = "HKCU:\Software\FirstLoginActions"
$startMenuWarmupRegistryName = "com.schoolyear.experimental-win11-start-menu-improvement"
$startMenuWarmed = Get-ItemPropertyValue -Path $firstLoginRegistryPath -Name $startMenuWarmupRegistryName -ErrorAction SilentlyContinue

function Get-VisibleAutomationNameCount {
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    if (-not $root) {
        return 0
    }

    $elements = $root.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.Condition]::TrueCondition
    )

    $names = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($element in $elements) {
        try {
            $name = $element.Current.Name
            if (![string]::IsNullOrWhiteSpace($name)) {
                [void]$names.Add($name)
            }
        } catch {
            continue
        }
    }

    return $names.Count
}
# This script is not critical, so it's wrapped in a try/catch
try {
    if ($startMenuWarmed -ne 1) {
        $wshell = New-Object -ComObject WScript.Shell
        $minimumAutomationNameCountChange = 3
        $baselineAutomationNameCount = Get-VisibleAutomationNameCount

        Write-Host "UIAutomation name count before opening Start menu: $baselineAutomationNameCount"

        $wshell.SendKeys('^{ESC}')
        Start-Sleep -Seconds 5

        $timeout = (Get-Date).AddSeconds(30)
        $closed = $false

        while ((Get-Date) -lt $timeout) {
            $currentAutomationNameCount = Get-VisibleAutomationNameCount
            $automationNameCountChange = [math]::Abs($currentAutomationNameCount - $baselineAutomationNameCount)

            if ($automationNameCountChange -ge $minimumAutomationNameCountChange) {
                Write-Host "Start menu detected by UIAutomation name count change ($baselineAutomationNameCount -> $currentAutomationNameCount), closing it..."
                $wshell.SendKeys('{ESC}')
                $closed = $true
                break
            }

            Write-Host "Start menu not detected yet. UIAutomation name count: $currentAutomationNameCount, change: $automationNameCountChange"
            Start-Sleep -Milliseconds 500
        }

        if (-not $closed) {
            Write-Host "Timed out after 30 seconds waiting for the Start menu name count to change by $minimumAutomationNameCountChange. Sending ESC anyway..."
            $wshell.SendKeys('{ESC}')
        } else {
            if (-not (Test-Path -LiteralPath $firstLoginRegistryPath)) {
                New-Item -Path $firstLoginRegistryPath -Force | Out-Null
            }

            New-ItemProperty `
                -Path $firstLoginRegistryPath `
                -Name $startMenuWarmupRegistryName `
                -Value 1 `
                -PropertyType DWord `
                -Force | Out-Null

            Write-Host "Start menu warm-up marked as completed for this user."
        }
    } else {
        Write-Host "Start menu warm-up already completed for this user. Skipping."
    }
} catch {
    Write-Host "Start menu warm-up failed: $($_.Exception.Message)"

    try {
        $fallbackShell = New-Object -ComObject WScript.Shell
        $fallbackShell.SendKeys('{ESC}')
        Write-Host "Sent ESC as failure cleanup."
    } catch {
        Write-Host "Failed to send ESC during failure cleanup: $($_.Exception.Message)"
    }
}
