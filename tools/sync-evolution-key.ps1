$ErrorActionPreference = 'Stop'
$runtimeEnv = docker inspect n8n --format '{{json .Config.Env}}' | ConvertFrom-Json
$n8nKey = (($runtimeEnv | Where-Object { $_ -like 'EVOLUTION_API_KEY=*' }) -replace '^EVOLUTION_API_KEY=', '')
if (!$n8nKey) { throw 'n8n EVOLUTION_API_KEY was not found.' }
$env:EVOLUTION_API_KEY = $n8nKey
& (Join-Path $PSScriptRoot 'recreate-secured-evolution.ps1')
Write-Output 'evolution_key_synchronized=true'
