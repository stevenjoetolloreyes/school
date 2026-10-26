-- Student Attendance Monitor — Supabase schema
-- Run this whole file in Supabase Dashboard > SQL Editor > New query.
-- Then turn OFF email confirmations for this school project:
-- Authentication > Providers > Email > Confirm email = OFF
-- (otherwise new accounts cannot sign in until they click an email link).

create table if not exists public.profiles (
  id uuid primary key,
  email text not null,
  role text not null check (role in ('teacher', 'student')),
  student_id text,
  created_at timestamptz default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  student_id text unique not null,
  name text not null,
  section text not null,
  gender text,
  status text not null default 'Active',
  created_at timestamptz default now()
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id text not null references public.students(student_id) on delete cascade,
  att_date date not null,
  status text not null check (status in ('Present', 'Late', 'Absent')),
  time_in text,
  created_at timestamptz default now(),
  unique (student_id, att_date)
);

alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.attendance enable row level security;

-- profiles: a user reads/creates/updates only their own profile
drop policy if exists "profiles own read" on public.profiles;
create policy "profiles own read" on public.profiles
  for select using (auth.uid() = id);
drop policy if exists "profiles own insert" on public.profiles;
create policy "profiles own insert" on public.profiles
  for insert with check (auth.uid() = id);
drop policy if exists "profiles own update" on public.profiles;
create policy "profiles own update" on public.profiles
  for update using (auth.uid() = id);

-- helper: is the caller a teacher?
-- (used inline in policies below; keep the EXISTS form so RLS stays simple)

-- students: teachers manage everything; a student reads only their own row;
-- a student may create their own row at registration (student_id = their profile's).
drop policy if exists "students teacher all" on public.students;
create policy "students teacher all" on public.students
  for all using (exists (select 1 from public.profiles where profiles.id = auth.uid() and profiles.role = 'teacher'));
drop policy if exists "students own read" on public.students;
create policy "students own read" on public.students
  for select using (student_id = (select student_id from public.profiles where profiles.id = auth.uid()));
drop policy if exists "students self insert" on public.students;
create policy "students self insert" on public.students
  for insert with check (student_id = (select student_id from public.profiles where profiles.id = auth.uid()));

-- attendance: teachers manage everything; a student reads only their own rows
drop policy if exists "attendance teacher all" on public.attendance;
create policy "attendance teacher all" on public.attendance
  for all using (exists (select 1 from public.profiles where profiles.id = auth.uid() and profiles.role = 'teacher'));
drop policy if exists "attendance own read" on public.attendance;
create policy "attendance own read" on public.attendance
  for select using (student_id = (select student_id from public.profiles where profiles.id = auth.uid()));
