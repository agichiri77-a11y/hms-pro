# HMS Pro — White-Label Hospitality Management System

A complete, multi-tenant hotel management system deployable on Netlify. Each hotel client gets their own Supabase database for full data isolation.

## Features

| Module | Description |
|--------|-------------|
| **Stock Control** | Inventory management, stock movements (in/out/adjustment), reorder alerts |
| **Requisitions** | Procurement requests with multi-level approval workflow |
| **Purchase Orders** | Full PO lifecycle with supplier integration and tax |
| **Expenditure** | Expense tracking with department/category breakdown |
| **Budgets** | Monthly/annual budgets vs actual expenditure |
| **Supplier Payments** | Payment recording and full supplier statement |
| **Fund Transfers** | Inter-account transfers with audit trail |
| **Double-Entry Ledger** | Journal entries, trial balance, chart of accounts |
| **Reports** | 9 role-filtered reports with charts |
| **Audit Log** | Immutable log of every system action |
| **User Management** | 5 roles with granular module access |

## Quick Start

### 1. Supabase Setup
1. Create a free project at [supabase.com](https://supabase.com)
2. Go to **Database → SQL Editor**
3. Paste and run `schema.sql`
4. Note your Project URL and `anon` key from **Settings → API**

### 2. Local Development
```bash
npm install
npm start
```

### 3. Deploy to Netlify
**Option A — Netlify CLI:**
```bash
npm run build
netlify deploy --prod --dir=build
```

**Option B — Netlify Dashboard:**
1. Push this repo to GitHub
2. Connect repo in Netlify → **New site from Git**
3. Build command: `npm run build`
4. Publish directory: `build`
5. Deploy!

### 4. First-Time Setup
On first visit, the **Setup Wizard** walks you through:
- Connecting your Supabase project
- Setting hotel name, currency, brand color
- Applying the database schema

**Default login:** `admin@hotel.com` / `admin123`
> ⚠️ Change the admin password immediately after first login!

## Multi-Tenant Architecture

Each hotel client:
1. Gets their own Supabase project (separate database)
2. Runs the same Netlify deployment (or their own)
3. Has their branding stored in `localStorage`

To onboard a new client, they simply visit your Netlify URL and complete the Setup Wizard with their Supabase credentials.

## User Roles

| Role | Access |
|------|--------|
| `admin` | Full access including setup, users, audit log |
| `manager` | Approvals, reports, all operational modules |
| `finance` | Financial modules: expenditure, ledger, payments, reports |
| `procurement` | Stock, requisitions, purchase orders |
| `staff` | Create requisitions only |

## Customisation

- **Brand colors**: Set in Setup Wizard, stored in `localStorage`
- **Currency**: Configurable per hotel (KES, USD, EUR, etc.)
- **Departments**: Managed in-app, pre-seeded with 6 defaults
- **Chart of Accounts**: 18 default accounts, expandable in-app

## Tech Stack

- **Frontend**: React 18, Recharts, Lucide
- **Backend**: Supabase (PostgreSQL + REST API)
- **Hosting**: Netlify (static SPA with redirects)
- **Fonts**: Sora (Google Fonts)
