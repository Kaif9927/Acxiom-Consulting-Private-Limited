# Event Management System

Express + MySQL app with **session auth**: legacy **memberships / events / bookings**, plus a **marketplace** flow (**admin**, **vendor**, **user** roles) aligned with the Technical Event Management wireframes—vendor directory, products, cart, checkout, order status, item requests, guest list, and admin maintenance for users and vendors.

## Project structure

| Folder | What it holds |
|--------|----------------|
| **`backend/`** | Node.js + Express: `server.js`, routes, controllers, DB config, `package.json` |
| **`frontend/`** | UI: `views/` (HTML pages), `public/` (CSS, JS, flowchart, assets) |
| **`database/`** | SQL: `init.sql` (full schema + seed + demo password repair), `upgrade_legacy.sql` (migrate old DBs) |

## Prerequisites

- Node.js 18+
- MySQL 8+ (or compatible)

## Database setup

All SQL lives under **`database/`**.

**New database** — from the repo root:

```bash
mysql -u root -p < database/init.sql
```

This creates `event`, all tables, seed data, and applies idempotent demo-password updates at the end.

**Existing `event` DB** (older install without marketplace) — add marketplace tables and `vendor` role:

```bash
mysql -u root -p < database/upgrade_legacy.sql
```

Do not run `upgrade_legacy.sql` on a database already created with `init.sql`.

Connection: `backend/config/db.js`. Env overrides:

- `DB_HOST` (default `127.0.0.1`)
- `DB_USER` (default `root`)
- `DB_PASSWORD` (**no default** — set locally or in production)
- `DB_NAME` (default `event`)
- **`ALLOWED_ORIGINS`** — optional, comma-separated browser origins (e.g. `http://localhost:5173`) allowed to call the API with **credentials**. If unset, only same-origin requests need no CORS. Use this when the frontend is served from another URL than the Express app.

See `backend/.env.example`.

## Run the app

```bash
cd backend
npm install
npm start
```

Open `http://localhost:3000`.

### Demo accounts (after `database/init.sql`)

| Role | Username | Password | Landing |
|------|-----------|----------|---------|
| Admin | `admin` | `admin123` | Any login → **`/dashboard.html`**, then Admin / Maintenance tiles |
| Vendor | `vendor1` | `vendor123` | Any login → **`/dashboard.html`**, nav **Vendor portal** |
| User | `user` | `user123` | Any login → **`/dashboard.html`**, nav **User portal** |

**Instruction** page: `/instruction.html`. **Flowchart**: `/flow` or `/flowchart.html`.

Set `SESSION_SECRET` in production.

## Key pages (marketplace)

- **Auth**: `login-admin.html`, `login-vendor.html`, `login-user.html`, `signup-*.html`
- **User**: `user-portal.html` (guest list), `vendors-list.html`, `products.html`, `cart.html`, `checkout.html`, `success.html`, `request-item.html`, `order-status-user.html`
- **Vendor**: `vendor-dashboard.html` (products CRUD), `vendor-product-status.html`, `vendor-update-order.html`
- **Admin**: `dashboard.html` (hub) with one **Maintenance** tile → `membership.html` (unified accounts table for admin/user/vendor with vendor shop columns; **Update** saves login + vendor profile; subscriptions add/extend/cancel/delete via user delete). Legacy admin URLs redirect here.

Also: `reports.html` (events / memberships).

## API overview

- **CORS**: Middleware in `server.js` reflects `ALLOWED_ORIGINS` for `Access-Control-Allow-Origin`, credentials, methods, headers, and answers `OPTIONS` preflight when the request `Origin` is in that list.
- Session cookie: `connect.sid`, ~30 min idle (`backend/server.js`).
- **Auth**: `POST /api/login`, `POST /api/register`, `POST /api/logout`, `GET /api/session` (login may send `expectedRole` to enforce portal).
- **Shop (customer)**: e.g. `GET /api/shop/vendors`, `GET /api/shop/products`, cart under `/api/shop/cart`, checkout `/api/shop/checkout`, guests `/api/shop/guests`, orders and item requests under `/api/shop/...`.
- **Vendor portal**: `/api/vendor/...` (profile, products, orders, fulfillment status, vendor-side item requests).
- **Admin marketplace**: `/api/admin/market/users`, `/api/admin/market/vendors` (CRUD).
- **Legacy admin**: memberships under `/api/memberships`, etc.

See route files in `backend/routes/` for exact paths and methods.
