const mysql = require('mysql2/promise');

require('./loadEnv').loadEnv();

// env vars override these if set
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  // keep password out of source control; set DB_PASSWORD in your host env
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'event',
  waitForConnections: true,
  connectionLimit: 10
});

module.exports = pool;
