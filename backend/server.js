const path = require('path');
const express = require('express');
const session = require('express-session');

const authRoutes = require('./routes/authRoutes');
const membershipRoutes = require('./routes/membershipRoutes');
const eventRoutes = require('./routes/eventRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

const frontendRoot = path.join(__dirname, '..', 'frontend');

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(
  session({
    secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
    resave: false,
    saveUninitialized: false,
    cookie: {
      maxAge: 30 * 60 * 1000,
      httpOnly: true
    }
  })
);

app.use('/api', authRoutes);
app.use('/api', membershipRoutes);
app.use('/api', eventRoutes);

function sendView(name) {
  return (req, res) => {
    res.sendFile(path.join(frontendRoot, 'views', name));
  };
}

app.get('/', sendView('login.html'));
app.get('/dashboard.html', sendView('dashboard.html'));
app.get('/membership.html', sendView('membership.html'));
app.get('/reports.html', sendView('reports.html'));

app.get('/flow', (req, res) => {
  res.redirect(302, '/flowchart.html');
});

app.use(express.static(path.join(frontendRoot, 'public')));

app.listen(PORT, () => {
  console.log('Server up on http://localhost:' + PORT);
});
