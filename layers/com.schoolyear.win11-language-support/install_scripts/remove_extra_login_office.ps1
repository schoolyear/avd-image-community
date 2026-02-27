# This script optionally removes the extra sign-in for Office apps when changing to a European language.
# The Digital Market Act interrupts SSO for Office, if the request is coming from a European device.
# This script works around this interrupt.
# As adapted from: https://call4cloud.nl/continue-to-sign-in-prompt-sso-dma/
# and https://call4cloud.nl/fix-continue-to-sign-in-prompt-dma-sso-compliance/
# tool used : https://github.com/thebookisclosed/ViVe/releases/download/v0.3.4/ViVeTool-v0.3.4-IntelAmd.zip
# license for Vivetool is included in the tool folder

$scriptLogPrefix = "Remove extra Office login"
$viveToolResourceDir = Join-Path (Split-Path $PSScriptRoot -Parent) "resources\ViVeTool-v0.3.4-IntelAmd"

$featureIds = @(47557358, 45833058)

if (-not (Test-Path -LiteralPath $viveToolResourceDir)) {
    throw "ViVeTool resource directory not found: $viveToolResourceDir"
}

$resourceViveToolExe = Get-ChildItem -Path $viveToolResourceDir -Filter "ViveTool.exe" -Recurse -File | Select-Object -First 1 -ExpandProperty FullName
if (-not $resourceViveToolExe) {
    throw "ViveTool.exe not found in resource directory: $viveToolResourceDir"
}

$viveToolExe = $resourceViveToolExe
Write-Host "${scriptLogPrefix}: Using ViVeTool directly from resources: $viveToolExe"

# Disable features
foreach ($featureId in $featureIds) {
    Write-Host "${scriptLogPrefix}: Disabling feature with ID $featureId"
    & $viveToolExe /disable /id:$featureId
}
 
# Query feature status
foreach ($featureId in $featureIds) {
    $queryresult = & $viveToolExe /query /id:$featureId
    @($queryresult) | ForEach-Object { Write-Host "${scriptLogPrefix}: $_" }
}
