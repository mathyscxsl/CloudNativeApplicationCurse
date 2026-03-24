#!/usr/bin/env powershell
# switch.ps1 – Bascule le reverse proxy vers la couleur cible (BLUE ou GREEN)
# Usage : powershell -File ./scripts/switch.ps1 -Target GREEN
#         powershell -File ./scripts/switch.ps1 -Target BLUE

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("BLUE","GREEN")]
    [string]$Target
)

$activeColorConf     = Join-Path $PSScriptRoot "..\nginx\active_color.conf"
$activeColorFrontConf = Join-Path $PSScriptRoot "..\nginx\active_color_front.conf"

if ($Target -eq "BLUE") {
    $backUpstream  = 'set $backend "app-back-blue:3000";' + "`nproxy_pass http://`$backend;"
    $frontUpstream = 'set $frontend "app-front-blue:80";' + "`nproxy_pass http://`$frontend;"
} else {
    $backUpstream  = 'set $backend "app-back-green:3000";' + "`nproxy_pass http://`$backend;"
    $frontUpstream = 'set $frontend "app-front-green:80";' + "`nproxy_pass http://`$frontend;"
}

Write-Host "==> Switching reverse proxy to $Target..."

$enc = [System.Text.Encoding]::ASCII
[System.IO.File]::WriteAllText((Resolve-Path $activeColorConf).Path, "$backUpstream`n", $enc)
[System.IO.File]::WriteAllText((Resolve-Path $activeColorFrontConf).Path, "$frontUpstream`n", $enc)

Write-Host "==> Reloading Nginx..."
docker exec reverse-proxy nginx -s reload

Write-Host "==> Active color is now: $Target"
