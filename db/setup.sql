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

-- Drop & recreate policies idempotently
do $$
declare t text;
begin
  foreach t in array array['sc_suggestions','sc_feedback','sc_tickets','sc_votes'] loop
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
