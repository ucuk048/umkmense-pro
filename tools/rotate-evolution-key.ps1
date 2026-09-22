$ErrorActionPreference = 'Stop'

$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
$env:EVOLUTION_API_KEY = [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')

& (Join-Path $PSScriptRoot 'recreate-secured-n8n.ps1')
& (Join-Path $PSScriptRoot 'recreate-secured-evolution.ps1')

$n8nPort = docker inspect n8n --format '{{json .HostConfig.PortBindings}}'
$evolutionPort = docker inspect evolution_api --format '{{json .HostConfig.PortBindings}}'
Write-Output "n8n_ports=$n8nPort"
Write-Output "evolution_ports=$evolutionPort"
Write-Output 'evolution_api_key_rotated=true'
