-- HMS Pro — Database Schema
-- Run this in your Supabase SQL Editor (Database → SQL Editor → New Query)
-- Execute all statements at once

-- =========================================================
-- TABLES
-- =========================================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'staff',
  department TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  budget NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  bank_name TEXT,
  account_number TEXT,
  balance NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stock_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS stock_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category_id UUID REFERENCES stock_categories(id),
  sku TEXT UNIQUE,
  unit TEXT NOT NULL DEFAULT 'pcs',
  quantity NUMERIC DEFAULT 0,
  reorder_level NUMERIC DEFAULT 0,
  unit_cost NUMERIC DEFAULT 0,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES stock_items(id),
  type TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  reference TEXT,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS requisitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ref_number TEXT UNIQUE NOT NULL,
  department_id UUID REFERENCES departments(id),
  requested_by UUID,
  status TEXT DEFAULT 'pending',
  priority TEXT DEFAULT 'normal',
  items JSONB NOT NULL DEFAULT '[]',
  total_amount NUMERIC DEFAULT 0,
  notes TEXT,
  approved_by UUID,
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number TEXT UNIQUE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  requisition_id UUID REFERENCES requisitions(id),
  status TEXT DEFAULT 'draft',
  items JSONB NOT NULL DEFAULT '[]',
  subtotal NUMERIC DEFAULT 0,
  tax_rate NUMERIC DEFAULT 0,
  tax_amount NUMERIC DEFAULT 0,
  total NUMERIC DEFAULT 0,
  delivery_date DATE,
  terms TEXT,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS expenditures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ref_number TEXT UNIQUE NOT NULL,
  department_id UUID REFERENCES departments(id),
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  payment_method TEXT DEFAULT 'Cash',
  vendor TEXT,
  receipt_number TEXT,
  approved_by UUID,
  status TEXT DEFAULT 'draft',
  date DATE NOT NULL,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID REFERENCES departments(id),
  period TEXT NOT NULL,
  year INT NOT NULL,
  month INT,
  category TEXT,
  allocated NUMERIC DEFAULT 0,
  spent NUMERIC DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  category TEXT,
  parent_id UUID,
  balance NUMERIC DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_number TEXT UNIQUE NOT NULL,
  date DATE NOT NULL,
  description TEXT NOT NULL,
  reference TEXT,
  total_debit NUMERIC DEFAULT 0,
  total_credit NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'posted',
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS journal_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID REFERENCES journal_entries(id),
  account_id UUID REFERENCES accounts(id),
  debit NUMERIC DEFAULT 0,
  credit NUMERIC DEFAULT 0,
  description TEXT
);

CREATE TABLE IF NOT EXISTS supplier_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ref_number TEXT UNIQUE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  po_id UUID REFERENCES purchase_orders(id),
  amount NUMERIC NOT NULL,
  payment_method TEXT DEFAULT 'Bank Transfer',
  bank_reference TEXT,
  payment_date DATE NOT NULL,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fund_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ref_number TEXT UNIQUE NOT NULL,
  from_account_id UUID REFERENCES accounts(id),
  to_account_id UUID REFERENCES accounts(id),
  amount NUMERIC NOT NULL,
  description TEXT,
  transfer_date DATE NOT NULL,
  status TEXT DEFAULT 'completed',
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  user_name TEXT,
  action TEXT NOT NULL,
  module TEXT NOT NULL,
  record_id TEXT,
  details JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =========================================================
-- SEED DATA
-- =========================================================

INSERT INTO users (name, email, password_hash, role) VALUES 
  ('System Admin', 'admin@hotel.com', 'admin123', 'admin')
ON CONFLICT (email) DO NOTHING;

INSERT INTO departments (name, code) VALUES
  ('Front Office', 'FO'),
  ('Food & Beverage', 'FB'),
  ('Housekeeping', 'HK'),
  ('Maintenance', 'MT'),
  ('Finance', 'FIN'),
  ('Administration', 'ADM')
ON CONFLICT (code) DO NOTHING;

INSERT INTO accounts (code, name, type, category) VALUES
  ('1000', 'Cash', 'asset', 'current'),
  ('1001', 'Bank Account', 'asset', 'current'),
  ('1100', 'Accounts Receivable', 'asset', 'current'),
  ('1200', 'Inventory', 'asset', 'current'),
  ('2000', 'Accounts Payable', 'liability', 'current'),
  ('2100', 'Accrued Expenses', 'liability', 'current'),
  ('3000', 'Owner Equity', 'equity', 'equity'),
  ('4000', 'Room Revenue', 'revenue', 'operating'),
  ('4100', 'F&B Revenue', 'revenue', 'operating'),
  ('4200', 'Other Revenue', 'revenue', 'other'),
  ('5000', 'Cost of Goods Sold', 'expense', 'cogs'),
  ('6000', 'Salaries & Wages', 'expense', 'operating'),
  ('6100', 'Utilities', 'expense', 'operating'),
  ('6200', 'Maintenance', 'expense', 'operating'),
  ('6300', 'Supplies', 'expense', 'operating'),
  ('6400', 'Marketing', 'expense', 'operating'),
  ('6500', 'Administrative', 'expense', 'operating'),
  ('6600', 'Depreciation', 'expense', 'operating')
ON CONFLICT (code) DO NOTHING;

-- =========================================================
-- ROW LEVEL SECURITY (Optional — enable for production)
-- =========================================================
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
-- (Configure policies based on your auth approach)
