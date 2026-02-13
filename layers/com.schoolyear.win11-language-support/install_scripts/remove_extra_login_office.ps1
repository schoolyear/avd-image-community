# As adapted from: https://call4cloud.nl/continue-to-sign-in-prompt-sso-dma/
# and https://call4cloud.nl/fix-continue-to-sign-in-prompt-dma-sso-compliance/

$downloadUrl = "https://github.com/thebookisclosed/ViVe/releases/download/v0.3.4/ViVeTool-v0.3.4-IntelAmd.zip"  # URL to download ViVe tool
$tempPath = "C:\Temp"
$viveToolDir = "$tempPath\ViVeTool"
New-Item -Path $viveToolDir -ItemType Directory -Force | Out-Null

$featureIds = @(47557358, 45833058)

Invoke-WebRequest -Uri $downloadUrl -OutFile "$viveToolDir\ViVeTool.zip"
Expand-Archive -Path "$viveToolDir\ViVeTool.zip" -DestinationPath $viveToolDir -Force
Write-Host "Downloaded and extracted ViVeTool."

# disable features
foreach ($featureId in $featureIds) {
    Write-Host "Disabling feature with ID $featureId."
    & "$viveToolDir\ViveTool.exe" /disable /id:$featureId
}
 
# Query status of features
foreach ($featureId in $featureIds) {  
$queryresult = & "$viveToolDir\ViveTool.exe" /query /id:$featureId  
Write-Host $queryresult  
}