-- Flashcards SRS — Supabase schema
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- Safe to re-run: every statement is guarded with IF NOT EXISTS / DROP ... IF EXISTS.

-- ---------------------------------------------------------------------------
-- cards: custom decks a signed-in user has imported (CSV/JSON). Bundled decks
-- (english_words.json, english_flashcards.json, english_grammar_tenses.json)
-- stay as static files and are never stored here.
-- ---------------------------------------------------------------------------
create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null default '',
  front text not null,
  back text not null,
  meaning text not null default '',
  example text not null default '',
  level text not null default 'B1',
  created_at timestamptz not null default now(),
  unique (user_id, type, front, back)
);

create index if not exists cards_user_id_idx on public.cards (user_id);

alter table public.cards enable row level security;

drop policy if exists "cards_select_own" on public.cards;
create policy "cards_select_own" on public.cards
  for select using (auth.uid() = user_id);

drop policy if exists "cards_insert_own" on public.cards;
create policy "cards_insert_own" on public.cards
  for insert with check (auth.uid() = user_id);

drop policy if exists "cards_update_own" on public.cards;
create policy "cards_update_own" on public.cards
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cards_delete_own" on public.cards;
create policy "cards_delete_own" on public.cards
  for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- progress: FSRS review state per card, for both bundled and custom cards.
-- card_id matches the app's client-side string id (e.g. "Idiom::break the ice::12"
-- for bundled cards, or the imported card's uuid for custom cards) — it is NOT
-- a foreign key, since bundled-deck cards are never rows in `cards`.
-- ---------------------------------------------------------------------------
create table if not exists public.progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  card_id text not null,
  state text not null default 'new',
  difficulty double precision not null default 0,
  stability double precision not null default 0,
  due bigint not null default 0,
  reps integer not null default 0,
  lapses integer not null default 0,
  interval double precision not null default 0,
  last_review bigint,
  updated_at timestamptz not null default now(),
  primary key (user_id, card_id)
);

alter table public.progress enable row level security;

drop policy if exists "progress_select_own" on public.progress;
create policy "progress_select_own" on public.progress
  for select using (auth.uid() = user_id);

drop policy if exists "progress_insert_own" on public.progress;
create policy "progress_insert_own" on public.progress
  for insert with check (auth.uid() = user_id);

drop policy if exists "progress_update_own" on public.progress;
create policy "progress_update_own" on public.progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "progress_delete_own" on public.progress;
create policy "progress_delete_own" on public.progress
  for delete using (auth.uid() = user_id);
