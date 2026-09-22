const fs = require('fs');
const s = require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3');
const db = new s.Database('/home/node/.n8n/database.sqlite');

const raw = JSON.parse(fs.readFileSync('/tmp/workflow_tidied.json', 'utf8'));
const wf = Array.isArray(raw) ? raw[0] : raw;
const nodesStr = JSON.stringify(wf.nodes);
const workflowId = 'DFfHShBWeBnOmmEp';

db.serialize(() => {
  db.run('UPDATE workflow_entity SET nodes = ? WHERE id = ?', [nodesStr, workflowId], function(err) {
    if (err) console.error('Error updating workflow_entity:', err);
    else console.log('Updated workflow_entity rows:', this.changes);
  });

  db.run('UPDATE workflow_history SET nodes = ? WHERE workflowId = ?', [nodesStr, workflowId], function(err) {
    if (err) console.error('Error updating workflow_history:', err);
    else console.log('Updated workflow_history rows:', this.changes);
  });

  db.get('SELECT id, versionId FROM workflow_entity WHERE id = ?', [workflowId], (err, row) => {
    if (err) console.error(err);
    else console.log('Workflow status:', row);
    db.close();
  });
});
