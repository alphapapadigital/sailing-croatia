-- ============================================================
-- Sailing Croatia · Supabase Schema
-- Run once: Supabase Dashboard → SQL Editor → New query → paste → Run
-- All tables prefixed sc_ to avoid collision with sibling projects.
-- ============================================================

-- Crew suggestions (new poll options / new questions)
create table if not exists public.sc_suggestions (
  id         bigserial primary key,
  created_at timestamptz not null default now(),
  from_name  text        not null,
  poll_id    text,                 -- null = brand-new poll, else target poll
  title      text        not null,
  detail     text,
  status     text        not null default 'open'  -- open | progress | done | reject
);

-- General feedback / wishes to admin
create table if not exists public.sc_feedback (
  id         bigserial primary key,
  created_at timestamptz not null default now(),
  from_name  text        not null,
  kind       text        not null default 'general',
  body       text        not null,
  status     text        not null default 'open'
);

-- Admin-side ticket log (manual entries from external channels)
create table if not exists public.sc_tickets (
  id         bigserial primary key,
  created_at timestamptz not null default now(),
  from_name  text        not null,
  kind       text        not null default 'other',  -- suggestion | feedback | pick | other
  title      text        not null,
  body       text,
  status     text        not null default 'open'
);

-- Cross-device voting (replaces localStorage poll-* keys)
create table if not exists public.sc_votes (
  voter_name   text not null,
  poll_id      text not null,
  option_index int  not null,
  updated_at   timestamptz not null default now(),
  primary key (voter_name, poll_id)
);

-- Cross-device polls (admin-managed via UI)
create table if not exists public.sc_polls (
  id          text primary key,
  question    text not null,
  options     jsonb not null,          -- array of strings
  order_index int  not null default 0,
  created_by  text,
  created_at  timestamptz not null default now()
);

-- Crew list (replaces localStorage crew-list)
-- id = lowercased+normalized name, so each name is unique across the crew
create table if not exists public.sc_crew (
  id          text primary key,
  name        text not null,
  nick        text,
  role        text,
  task        text,
  from_date   date,
  to_date     date,
  plan        text,
  order_index int  not null default 100,  -- lower = higher in list
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Crew-cooking plan (dishes to cook on board)
create table if not exists public.sc_cooking (
  id         bigserial primary key,
  dish       text not null,
  who_cooks  text,
  day        text,            -- e.g. 'Sa 30.5', free-form
  notes      text,
  by_name    text,
  done       boolean not null default false,
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- This is a friends-only app gated by a shared password.
-- We allow anon CRUD; the trust boundary is the login overlay.
-- (If we ever go public, swap to authenticated-only policies.)
-- ============================================================
alter table public.sc_suggestions enable row level security;
alter table public.sc_feedback    enable row level security;
alter table public.sc_tickets     enable row level security;
alter table public.sc_votes       enable row level security;
alter table public.sc_polls       enable row level security;
alter table public.sc_crew        enable row level security;
alter table public.sc_cooking     enable row level security;

-- Drop & recreate policies idempotently
do $$
declare t text;
begin
  foreach t in array array['sc_suggestions','sc_feedback','sc_tickets','sc_votes','sc_polls','sc_crew','sc_cooking'] loop
    execute format('drop policy if exists "%s_all_select" on public.%I', t, t);
    execute format('drop policy if exists "%s_all_insert" on public.%I', t, t);
    execute format('drop policy if exists "%s_all_update" on public.%I', t, t);
    execute format('drop policy if exists "%s_all_delete" on public.%I', t, t);
    execute format('create policy "%s_all_select" on public.%I for select using (true)', t, t);
    execute format('create policy "%s_all_insert" on public.%I for insert with check (true)', t, t);
    execute format('create policy "%s_all_update" on public.%I for update using (true) with check (true)', t, t);
    execute format('create policy "%s_all_delete" on public.%I for delete using (true)', t, t);
  end loop;
end $$;

-- Indexes for the queries we'll run
create index if not exists sc_suggestions_created_idx on public.sc_suggestions (created_at desc);
create index if not exists sc_feedback_created_idx    on public.sc_feedback    (created_at desc);
create index if not exists sc_tickets_status_idx      on public.sc_tickets     (status, created_at desc);
create index if not exists sc_votes_poll_idx          on public.sc_votes       (poll_id);
create index if not exists sc_polls_order_idx         on public.sc_polls       (order_index, created_at);
create index if not exists sc_crew_order_idx          on public.sc_crew        (order_index, name);
create index if not exists sc_cooking_created_idx     on public.sc_cooking     (created_at desc);

-- ============================================================
-- One-time hygiene: drop any "Peter Test" / "test" rows that leaked in
-- (case-insensitive). Idempotent: safe to re-run.
-- ============================================================
delete from public.sc_crew      where lower(name) in ('peter test','test','testuser');
delete from public.sc_votes     where lower(voter_name) in ('peter test','test','testuser');
delete from public.sc_suggestions where lower(from_name) in ('peter test','test','testuser');
delete from public.sc_feedback   where lower(from_name) in ('peter test','test','testuser');

-- ============================================================
-- Seed crew (only if sc_crew is empty). DEFAULT_CREW + Leon.
-- Subsequent edits via the app overwrite these rows by id.
-- ============================================================
insert into public.sc_crew (id, name, nick, role, task, from_date, to_date, order_index)
select * from (values
  ('simon',  'Simon',  'Käpt''n Sim',     '🧭 Captain',                'Plan, Knoten, Manöver – der mit dem Wetter im Kopf', date '2026-05-30', date '2026-06-06',  10),
  ('andre',  'André',  'Sommelier-Dré',   '🍷 Aperol-Beauftragter',    'Drink-Karte, Sundowner-Timing, Spotify-Co-Pilot',     date '2026-05-30', date '2026-06-06',  20),
  ('jana',   'Jana',   'Sunny Jane',      '☀️ Sun-Manager',             'Sonnencreme-Polizei + Buchten-Scout',                  date '2026-05-30', date '2026-06-06',  30),
  ('mona',   'Mona',   'Chefin Mo',       '🍽️ Chef de Cuisine',         'Restaurant-Scout, Reservierungs-Queen',                date '2026-05-30', date '2026-06-06',  40),
  ('hans',   'Hans',   'Anker-Hans',      '⚓ Bootsmann',                'Anker, Fender, Leinen – der mit dem Knoten-Wissen',    date '2026-05-30', date '2026-06-06',  50),
  ('alessa', 'Alessa', 'DJ Less',         '🎶 DJ an Bord',              'Spotify-Boss, Sundowner-Soundtrack',                   date '2026-05-30', date '2026-06-06',  60),
  ('luzy',   'Luzy',   'Insta-Lu',        '📸 Foto-Beauftragte',        'Drohnen-Shots, Crew-Reels, Reise-Doku',                date '2026-05-30', date '2026-06-06',  70),
  ('leon',   'Leon',   'Lucky Leo',       '🍀 Crew-Glücksbringer',      'Stimmungs-Hochhalter, Aperol-Wingman',                 date '2026-05-30', date '2026-06-06',  80)
) as v(id,name,nick,role,task,from_date,to_date,order_index)
where not exists (select 1 from public.sc_crew);

-- Ensure Leon exists even if crew was already seeded earlier without him
insert into public.sc_crew (id, name, nick, role, task, from_date, to_date, order_index)
values ('leon', 'Leon', 'Lucky Leo', '🍀 Crew-Glücksbringer', 'Stimmungs-Hochhalter, Aperol-Wingman', date '2026-05-30', date '2026-06-06', 80)
on conflict (id) do nothing;
