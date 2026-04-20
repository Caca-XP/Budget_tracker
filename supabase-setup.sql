-- ── Run this in Supabase → SQL Editor ───────────────────────────────────────
-- Creates the transactions table and seeds it with your existing data.

-- 1. Create table
create table if not exists transactions (
  id          bigint generated always as identity primary key,
  date        text    not null,   -- YYYY-MM-DD
  type        text    not null,
  amount      numeric not null check (amount > 0),
  fortnight   int     not null check (fortnight >= 1),
  description text    not null
);

-- 2. Allow public read + insert (no login required — it's your personal app)
alter table transactions enable row level security;

create policy "Allow anon select"
  on transactions for select
  using (true);

create policy "Allow anon insert"
  on transactions for insert
  with check (true);

-- 3. Seed with existing data
insert into transactions (date, type, amount, fortnight, description) values
  ('2026-03-18', 'Salary',               2491.21, 1, 'Payday'),
  ('2026-03-19', 'Emergency',              72.00, 1, 'Auto'),
  ('2026-03-19', 'Spending',               72.09, 1, 'Sake festival for Sep'),
  ('2026-03-20', 'Investment',           1160.00, 1, 'Stake'),
  ('2026-03-21', 'Transport',              40.00, 1, 'Transport NSW'),
  ('2026-03-21', 'Spending',               25.36, 1, 'Eating out'),
  ('2026-03-21', 'Miscellaneous expense',   6.98, 1, 'Soap'),
  ('2026-03-21', 'Spending',               10.60, 1, 'Daiso'),
  ('2026-03-21', 'Spending',               17.22, 1, 'My unique life'),
  ('2026-03-21', 'Rent',                  840.00, 1, 'Cash'),
  ('2026-03-24', 'Travel',                120.00, 1, 'in emergency'),
  ('2026-03-26', 'Miscellaneous expense',  13.00, 1, 'Plants'),
  ('2026-03-28', 'Miscellaneous expense',   8.35, 1, 'Catnip plant'),
  ('2026-03-28', 'Spending',                9.05, 1, 'Snacks'),
  ('2026-03-28', 'Miscellaneous expense',   5.00, 1, 'Yoga mat'),
  ('2026-03-29', 'Transport',              40.00, 1, 'Transport NSW'),
  ('2026-04-01', 'Salary',               2491.21, 2, 'Payday'),
  ('2026-04-02', 'Emergency',              72.00, 2, 'Auto'),
  ('2026-04-02', 'Travel',                120.00, 2, 'in emergency'),
  ('2026-04-01', 'Investment',           1160.00, 2, 'Stake'),
  ('2026-04-02', 'Spending',               33.50, 2, 'Eating out'),
  ('2026-04-02', 'Miscellaneous expense',   5.85, 2, 'Dental and Bleach'),
  ('2026-04-03', 'Spending',               50.87, 2, 'Easter show'),
  ('2026-04-05', 'Rent',                  840.00, 2, 'Cash'),
  ('2026-04-07', 'Spending',              125.00, 2, 'CBA ball'),
  ('2026-04-07', 'Transport',              35.00, 2, 'Transport NSW'),
  ('2026-04-11', 'Spending',               54.05, 2, 'Easter show expenses'),
  ('2026-04-15', 'Salary',               2491.21, 3, 'Payday'),
  ('2026-04-15', 'Spending',               16.75, 3, 'Anime Rave'),
  ('2026-04-15', 'Transport',              40.00, 3, 'Transport NSW'),
  ('2026-04-15', 'Investment',           1160.00, 3, 'Stake'),
  ('2026-04-15', 'Spending',               10.00, 3, 'Easter show expenses'),
  ('2026-04-16', 'Emergency',              72.00, 3, 'Auto'),
  ('2026-04-16', 'Travel',                120.00, 3, 'in emergency'),
  ('2026-04-16', 'Rent',                  840.00, 3, 'Cash'),
  ('2026-04-18', 'Spending',               23.00, 3, 'Eating out');
