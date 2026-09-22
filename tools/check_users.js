const s = require('/usr/local/lib/node_modules/n8n/node_modules/sqlite3');
const db = new s.Database('/home/node/.n8n/database.sqlite');

db.all('SELECT id, email, firstName, lastName FROM "user"', (err, rows) => {
  if (err) console.error(err.message);
  else console.log('Users:', rows);
  db.close();
});
