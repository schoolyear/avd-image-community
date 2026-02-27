# As adapted from: https://call4cloud.nl/continue-to-sign-in-prompt-sso-dma/
# and https://call4cloud.nl/fix-continue-to-sign-in-prompt-dma-sso-compliance/
# tool used : https://github.com/thebookisclosed/ViVe/releases/download/v0.3.4/ViVeTool-v0.3.4-IntelAmd.zip

$scriptLogPrefix = "Remove extra login office"
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

# disable features
foreach ($featureId in $featureIds) {
    Write-Host "${scriptLogPrefix}: Disabling feature with ID $featureId"
    & $viveToolExe /disable /id:$featureId
}
 
# Query status of features
foreach ($featureId in $featureIds) {
    $queryresult = & $viveToolExe /query /id:$featureId
    @($queryresult) | ForEach-Object { Write-Host "${scriptLogPrefix}: $_" }
}
