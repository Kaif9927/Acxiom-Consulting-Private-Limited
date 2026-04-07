const bcrypt = require('bcryptjs');
const db = require('../config/db');

async function login(req, res) {
  const username = (req.body.username || '').trim();
  const password = req.body.password || '';

  if (!username || !password) {
    return res.status(400).json({ ok: false, message: 'Username and password are required.' });
  }

  try {
    const [rows] = await db.query(
      'SELECT id, username, password, role FROM users WHERE username = ? LIMIT 1',
      [username]
    );

    if (rows.length === 0) {
      return res.status(401).json({ ok: false, message: 'Bad username or password.' });
    }

    const row = rows[0];
    const match = await bcrypt.compare(password, row.password);
    if (!match) {
      return res.status(401).json({ ok: false, message: 'Bad username or password.' });
    }

    req.session.userId = row.id;
    req.session.username = row.username;
    req.session.role = row.role;

    return res.json({
      ok: true,
      user: { id: row.id, username: row.username, role: row.role }
    });
  } catch (err) {
    console.error('login err', err);
    return res.status(500).json({ ok: false, message: 'Something went wrong, try again.' });
  }
}

function logout(req, res) {
  req.session.destroy(() => {
    res.clearCookie('connect.sid');
    res.json({ ok: true });
  });
}

function sessionInfo(req, res) {
  if (!req.session.userId) {
    return res.status(401).json({ ok: false, message: 'Not logged in.' });
  }
  res.json({
    ok: true,
    user: {
      id: req.session.userId,
      username: req.session.username,
      role: req.session.role
    }
  });
}

function requireAuth(req, res, next) {
  if (!req.session || !req.session.userId) {
    return res.status(401).json({ ok: false, message: 'Session expired or not logged in.' });
  }
  next();
}

function requireAdmin(req, res, next) {
  if (req.session.role !== 'admin') {
    return res.status(403).json({ ok: false, message: 'Admins only for that.' });
  }
  next();
}

module.exports = {
  login,
  logout,
  sessionInfo,
  requireAuth,
  requireAdmin
};
