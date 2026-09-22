$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$candidate = Join-Path $workspace 'My workflow (WhatsApp Dewa) - remediated-v35-ultimate.json'
$workflowName = 'UMKMense Pro - AI Financial Agent (WhatsApp Edition V35)'

# Idempotent startup: reuse existing workflow and import only when missing.
$lookup = @"
const s=require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3');const db=new s.Database('/home/node/.n8n/database.sqlite');db.get('SELECT id, active FROM workflow_entity WHERE name = ? ORDER BY rowid DESC LIMIT 1',['$workflowName'],(e,r)=>{if(e){console.error(e.message);process.exit(1)}console.log(JSON.stringify(r||{}));db.close()});
"@
$statusRaw = (docker exec n8n node -e $lookup).Trim()
$status = $statusRaw | ConvertFrom-Json
$existingId = $status.id
$alreadyActive = ($status.active -eq 1)

if (!$existingId) {
  if (Test-Path $candidate) {
    docker cp $candidate n8n:/tmp/umkmense-remediated-v35.json
    docker exec n8n n8n import:workflow --input=/tmp/umkmense-remediated-v35.json
    if ($LASTEXITCODE -ne 0) { throw 'Could not import remediated v35 ultimate workflow.' }
  }
}

$nodeCode = @"
const s=require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3');const db=new s.Database('/home/node/.n8n/database.sqlite');db.serialize(()=>{db.get('SELECT id,versionId FROM workflow_entity WHERE name = ? ORDER BY rowid DESC LIMIT 1',['$workflowName'],(e,row)=>{if(e||!row){console.error(e?.message||'v35 workflow not found');process.exitCode=1;db.close();return;}db.all('SELECT id FROM workflow_entity WHERE name LIKE ?',['UMKMense Pro - AI Financial Agent%'],(e2,rows)=>{if(e2){console.error(e2.message);process.exitCode=1;db.close();return;}for(const x of rows||[])if(x.id!==row.id)db.run('UPDATE workflow_entity SET active=0,activeVersionId=NULL WHERE id=?',[x.id]);db.run('UPDATE workflow_entity SET active=1,activeVersionId=? WHERE id=?',[row.versionId,row.id]);db.run('INSERT OR REPLACE INTO workflow_published_version (workflowId,publishedVersionId) VALUES (?,?)',[row.id,row.versionId]);db.run('SELECT 1',[],()=>{console.log(JSON.stringify({workflowId:row.id,reused:true}));db.close()})})})});
"@
docker exec n8n node -e $nodeCode
if ($LASTEXITCODE -ne 0) { throw 'Could not activate v35 workflow.' }
if (!$alreadyActive) { docker restart n8n | Out-Null }
$health=$null
for($attempt=1;$attempt -le 12;$attempt++){Start-Sleep -Seconds 2;try{$health=Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 http://127.0.0.1:5678/healthz;if($health.StatusCode -eq 200){break}}catch{}}
if(!$health -or $health.StatusCode -ne 200){throw 'n8n did not become healthy.'}
Write-Output "n8n_health=$($health.StatusCode) workflow_reused=$([bool]$existingId)"