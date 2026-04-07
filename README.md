# Event Management System

Small Express + MySQL app for memberships, events, and bookings. Session auth (no JWT).

## Project structure

| Folder | What it holds |
|--------|----------------|
| **`backend/`** | Node.js + Express: `server.js`, routes, controllers, DB config, `package.json` |
| **`frontend/`** | UI: `views/` (HTML pages), `public/` (CSS, JS, static pages like flowchart) |
| **`database/`** | SQL: schema + seed data, password-fix script |

## Prerequisites

- Node.js 18+
- MySQL 8+ (or compatible)

## Database setup

From the **repository root** (folder that contains `backend/`, `database/`):

```bash
mysql -u root -p < database/schema.sql
```

Optional — reset demo password hashes if logins fail:

```bash
mysql -u root -p < database/fix-demo-passwords.sql
```

Connection settings: `backend/config/db.js`. Defaults: database `event`, user `root`. Override with env:

- `DB_HOST` (default `127.0.0.1`)
- `DB_USER` (default `root`)
- `DB_PASSWORD` (**no default in code** — set in production)
- `DB_NAME` (default `event`)

## Run the app

```bash
cd backend
npm install
npm start
```

Open `http://localhost:3000`. Demo accounts after seeding:

- **admin** / `admin123` — maintenance + reports + transactions
- **user** / `user123` — reports + transactions only

Set `SESSION_SECRET` in production.

## API notes

- Session cookie: `connect.sid`, ~30 min idle (see `backend/server.js`).
- Admin-only: `POST /api/memberships`, `GET /api/memberships/:id`, `POST /api/memberships/update`, `GET /api/users-for-membership`.
- All authenticated users: reports, events list, book event, own transactions.
