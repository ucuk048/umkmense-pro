const s = require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3');
const db = new s.Database('/home/node/.n8n/database.sqlite');

db.all("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%workflow%'", (err, tables) => {
  console.log('Tables:', tables);
  db.all("SELECT versionId, workflowId, length(nodes) as nlen FROM workflow_history WHERE workflowId='DFfHShBWeBnOmmEp' ORDER BY createdAt DESC LIMIT 5", (e2, hists) => {
    if (e2) console.log('No workflow_history or error:', e2.message);
    else console.log('workflow_history:', hists);
    db.close();
  });
});
