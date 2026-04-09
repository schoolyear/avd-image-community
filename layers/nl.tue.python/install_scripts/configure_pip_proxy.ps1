Param ()

$scriptName = Split-Path -Path $PSCommandPath -Leaf
$scriptLogPrefix = "Python pip proxy"
$defaultUserProfile = "C:\Users\Default"
$proxyUrl = "http://proxies.local:8080"
$pipDir = Join-Path -Path $defaultUserProfile -ChildPath "pip"
$pipIniPath = Join-Path -Path $pipDir -ChildPath "pip.ini"
$pipIniContent = @"
[global]
trusted-host =  pypi.python.org
                pypi.org
                files.pythonhosted.org
proxy = $proxyUrl
"@

if (!(Test-Path $pipDir)) {
  Write-Host "${scriptLogPrefix}: Creating $pipDir"
  New-Item -Path $pipDir -ItemType Directory -Force | Out-Null
}

Write-Host "${scriptLogPrefix}: Writing pip.ini file at $pipIniPath"
Set-Content -Path $pipIniPath -Value $pipIniContent

if (!(Test-Path $pipIniPath)) {
  throw "pip.ini was not found at $pipIniPath after writing"
}

Write-Host "${scriptLogPrefix}: Wrote $pipIniPath"
