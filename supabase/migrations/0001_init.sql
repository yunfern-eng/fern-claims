create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  name text not null,
  created_at timestamptz not null default now()
);
alter table companies enable row level security;
drop policy if exists "companies_v1_read" on companies;
create policy "companies_v1_read" on companies for select using (true);
drop policy if exists "companies_v1_write" on companies;
create policy "companies_v1_write" on companies for all using (true) with check (true);

create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  company_id uuid references companies(id) on delete set null,
  vendor_name text not null,
  invoice_number text,
  invoice_date date,
  amount numeric(12,2) not null default 0,
  currency text not null default 'SGD',
  category text,
  category_source text default 'manual',
  category_confidence numeric default 1.0,
  category_review_status text default 'unreviewed',
  file_url text,
  status text not null default 'unmatched',
  created_at timestamptz not null default now()
);
alter table invoices enable row level security;
drop policy if exists "invoices_v1_read" on invoices;
create policy "invoices_v1_read" on invoices for select using (true);
drop policy if exists "invoices_v1_write" on invoices;
create policy "invoices_v1_write" on invoices for all using (true) with check (true);

create table if not exists cc_statements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  company_id uuid references companies(id) on delete set null,
  statement_month date not null,
  file_url text,
  total_amount numeric(12,2) default 0,
  created_at timestamptz not null default now()
);
alter table cc_statements enable row level security;
drop policy if exists "cc_statements_v1_read" on cc_statements;
create policy "cc_statements_v1_read" on cc_statements for select using (true);
drop policy if exists "cc_statements_v1_write" on cc_statements;
create policy "cc_statements_v1_write" on cc_statements for all using (true) with check (true);

create table if not exists cc_statement_lines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  cc_statement_id uuid not null references cc_statements(id) on delete cascade,
  transaction_date date,
  description text,
  amount numeric(12,2) not null default 0,
  matched_invoice_id uuid references invoices(id) on delete set null,
  match_status text not null default 'unmatched',
  match_source text,
  match_confidence numeric,
  match_review_status text default 'unreviewed',
  created_at timestamptz not null default now()
);
alter table cc_statement_lines enable row level security;
drop policy if exists "cc_statement_lines_v1_read" on cc_statement_lines;
create policy "cc_statement_lines_v1_read" on cc_statement_lines for select using (true);
drop policy if exists "cc_statement_lines_v1_write" on cc_statement_lines;
create policy "cc_statement_lines_v1_write" on cc_statement_lines for all using (true) with check (true);

create table if not exists claims (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  company_id uuid not null references companies(id) on delete cascade,
  period_month date not null,
  title text not null,
  status text not null default 'draft',
  created_at timestamptz not null default now()
);
alter table claims enable row level security;
drop policy if exists "claims_v1_read" on claims;
create policy "claims_v1_read" on claims for select using (true);
drop policy if exists "claims_v1_write" on claims;
create policy "claims_v1_write" on claims for all using (true) with check (true);

create table if not exists claim_invoices (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references claims(id) on delete cascade,
  invoice_id uuid not null references invoices(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table claim_invoices enable row level security;
drop policy if exists "claim_invoices_v1_read" on claim_invoices;
create policy "claim_invoices_v1_read" on claim_invoices for select using (true);
drop policy if exists "claim_invoices_v1_write" on claim_invoices;
create policy "claim_invoices_v1_write" on claim_invoices for all using (true) with check (true);

create table if not exists expenditure_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  claim_id uuid not null references claims(id) on delete cascade,
  total_amount numeric(12,2) default 0,
  category_breakdown jsonb default '{}'::jsonb,
  vendor_breakdown jsonb default '{}'::jsonb,
  unmatched_amount numeric(12,2) default 0,
  generated_at timestamptz not null default now()
);
alter table expenditure_summaries enable row level security;
drop policy if exists "expenditure_summaries_v1_read" on expenditure_summaries;
create policy "expenditure_summaries_v1_read" on expenditure_summaries for select using (true);
drop policy if exists "expenditure_summaries_v1_write" on expenditure_summaries;
create policy "expenditure_summaries_v1_write" on expenditure_summaries for all using (true) with check (true);

insert into companies (id, name) values
  ('a1111111-1111-1111-1111-111111111111', 'Acme Holdings Pte Ltd'),
  ('b2222222-2222-2222-2222-222222222222', 'Brightspire Media Pte Ltd')
on conflict (id) do nothing;

insert into invoices (id, company_id, vendor_name, invoice_number, invoice_date, amount, currency, category, status, file_url) values
  ('c1a1a1a1-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Google Ads', 'GOOG-2025-01', '2025-01-05', 2500.00, 'SGD', 'Advertising', 'matched', null),
  ('c1a1a1a1-2222-2222-2222-222222222222', 'a1111111-1111-1111-1111-111111111111', 'Microsoft 365', 'MS-2025-01', '2025-01-08', 320.00, 'SGD', 'Software', 'matched', null),
  ('c1a1a1a1-3333-3333-3333-333333333333', 'a1111111-1111-1111-1111-111111111111', 'Slack', 'SLACK-2025-01', '2025-01-10', 180.00, 'SGD', 'Software', 'matched', null),
  ('c1a1a1a1-4444-4444-4444-444444444444', 'a1111111-1111-1111-1111-111111111111', 'Shopee Ads', 'SHP-2025-01', '2025-01-12', 850.00, 'SGD', 'Advertising', 'matched', null),
  ('c1a1a1a1-5555-5555-5555-555555555555', 'a1111111-1111-1111-1111-111111111111', 'Grab for Business', 'GRAB-2025-01', '2025-01-15', 95.00, 'SGD', 'Transport', 'unmatched', null),
  ('d2b2b2b2-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 'Meta Ads', 'META-2025-01', '2025-01-06', 4200.00, 'SGD', 'Advertising', 'matched', null),
  ('d2b2b2b2-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'Figma', 'FIG-2025-01', '2025-01-09', 75.00, 'SGD', 'Software', 'matched', null),
  ('d2b2b2b2-3333-3333-3333-333333333333', 'b2222222-2222-2222-2222-222222222222', 'Amazon Web Services', 'AWS-2025-01', '2025-01-14', 1300.00, 'SGD', 'Cloud Infrastructure', 'matched', null)
on conflict (id) do nothing;

insert into cc_statements (id, company_id, statement_month, total_amount, file_url) values
  ('e3e3e3e3-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', '2025-01-01', 3945.00, null)
on conflict (id) do nothing;

insert into cc_statement_lines (id, cc_statement_id, transaction_date, description, amount, matched_invoice_id, match_status, match_source, match_confidence) values
  ('f4f4f4f4-1111-1111-1111-111111111111', 'e3e3e3e3-1111-1111-1111-111111111111', '2025-01-05', 'GOOGLE*ADS', 2500.00, 'c1a1a1a1-1111-1111-1111-111111111111', 'matched', 'rule', 0.95),
  ('f4f4f4f4-2222-2222-2222-222222222222', 'e3e3e3e3-1111-1111-1111-111111111111', '2025-01-08', 'MICROSOFT 365', 320.00, 'c1a1a1a1-2222-2222-2222-222222222222', 'matched', 'rule', 0.95),
  ('f4f4f4f4-3333-3333-3333-333333333333', 'e3e3e3e3-1111-1111-1111-111111111111', '2025-01-10', 'SLACK TECH', 180.00, 'c1a1a1a1-3333-3333-3333-333333333333', 'matched', 'rule', 0.90),
  ('f4f4f4f4-4444-4444-4444-444444444444', 'e3e3e3e3-1111-1111-1111-111111111111', '2025-01-12', 'SHOPEE ADS', 850.00, 'c1a1a1a1-4444-4444-4444-444444444444', 'matched', 'rule', 0.92),
  ('f4f4f4f4-5555-5555-5555-555555555555', 'e3e3e3e3-1111-1111-1111-111111111111', '2025-01-20', 'UNKNOWN CHARGE', 45.00, null, 'unmatched', null, null)
on conflict (id) do nothing;

insert into claims (id, company_id, period_month, title, status) values
  ('a5a5a5a5-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', '2025-01-01', 'Acme Holdings — January 2025 Claims', 'draft')
on conflict (id) do nothing;

insert into claim_invoices (claim_id, invoice_id) values
  ('a5a5a5a5-1111-1111-1111-111111111111', 'c1a1a1a1-1111-1111-1111-111111111111'),
  ('a5a5a5a5-1111-1111-1111-111111111111', 'c1a1a1a1-2222-2222-2222-222222222222'),
  ('a5a5a5a5-1111-1111-1111-111111111111', 'c1a1a1a1-3333-3333-3333-333333333333'),
  ('a5a5a5a5-1111-1111-1111-111111111111', 'c1a1a1a1-4444-4444-4444-444444444444')
on conflict do nothing;

insert into expenditure_summaries (id, claim_id, total_amount, category_breakdown, vendor_breakdown, unmatched_amount, generated_at) values
  ('b6b6b6b6-1111-1111-1111-111111111111', 'a5a5a5a5-1111-1111-1111-111111111111', 3850.00, '{"Advertising": 3350.00, "Software": 500.00}'::jsonb, '{"Google Ads": 2500.00, "Microsoft 365": 320.00, "Slack": 180.00, "Shopee Ads": 850.00}'::jsonb, 45.00, now())
on conflict (id) do nothing;