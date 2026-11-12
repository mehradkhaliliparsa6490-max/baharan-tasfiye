-- ============================================================
-- راه‌اندازی Supabase — «دفتر خدمات فنی بهاران تصفیه»
-- ۱) پروژه رایگان در supabase.com بسازید.
-- ۲) Authentication ← Users ← Add user: ایمیل و رمز مدیر (Auto Confirm User).
-- ۳) Authentication ← Sign In / Providers ← «Allow new users to sign up» را خاموش کنید.
-- ۴) در همین فایل، ایمیل CHANGE_ME@example.com را (۲ جا) با ایمیل مدیر عوض کنید.
-- ۵) SQL Editor ← این فایل را اجرا کنید.
-- ۶) Project URL و anon key را (Project Settings ← API) در بالای اسکریپت index.html بگذارید.
-- ============================================================

create table if not exists public.requests (
  id         uuid primary key default gen_random_uuid(),
  name       text not null check (char_length(name)    between 1 and 100),
  phone      text not null check (char_length(phone)   between 8 and 20),
  service    text not null check (char_length(service) between 1 and 200),
  address    text check (char_length(address) <= 400),
  req_date   date,
  note       text check (char_length(note) <= 1000),
  status     text not null default 'pending' check (status in ('pending','done')),
  source     text not null default 'online',
  created_at timestamptz not null default now(),
  done_at    timestamptz
);

create table if not exists public.records (
  id         text primary key,
  kind       text not null,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.requests enable row level security;
alter table public.records  enable row level security;

-- مشتری (بدون ورود): فقط ثبت درخواست، آن هم فقط در ستون‌های مجاز
revoke all on public.requests from anon;
revoke all on public.records  from anon;
grant insert (name, phone, service, address, req_date, note) on public.requests to anon;
grant all on public.requests to authenticated;
grant all on public.records  to authenticated;

drop policy if exists "anon insert" on public.requests;
create policy "anon insert" on public.requests
  for insert to anon with check (true);

-- مدیر: فقط ایمیل مشخص‌شده
drop policy if exists "admin requests" on public.requests;
create policy "admin requests" on public.requests
  for all to authenticated
  using ((auth.jwt() ->> 'email') = 'CHANGE_ME@example.com')
  with check ((auth.jwt() ->> 'email') = 'CHANGE_ME@example.com');

drop policy if exists "admin records" on public.records;
create policy "admin records" on public.records
  for all to authenticated
  using ((auth.jwt() ->> 'email') = 'CHANGE_ME@example.com')
  with check ((auth.jwt() ->> 'email') = 'CHANGE_ME@example.com');
