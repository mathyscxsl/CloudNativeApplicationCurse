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
    $backUpstream  = "proxy_pass http://app_blue_back;"
    $frontUpstream = "proxy_pass http://app_blue_front;"
} else {
    $backUpstream  = "proxy_pass http://app_green_back;"
    $frontUpstream = "proxy_pass http://app_green_front;"
}

Write-Host "==> Switching reverse proxy to $Target..."

Set-Content -Path $activeColorConf      -Value $backUpstream  -Encoding utf8
Set-Content -Path $activeColorFrontConf -Value $frontUpstream -Encoding utf8

Write-Host "==> Reloading Nginx..."
docker exec reverse-proxy nginx -s reload

Write-Host "==> Active color is now: $Target"
