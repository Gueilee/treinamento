-- Quiz Finanças Ao Vivo — schema inicial
-- Rode este script no Supabase Dashboard > SQL Editor > New query > Run

create table if not exists public.participants (
  id uuid primary key default gen_random_uuid(),
  viewer_id text unique not null,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.live_state (
  id int primary key default 1,
  phase text not null default 'lobby',
  round text,
  mode text,
  order_ids jsonb,
  current_index int not null default 0,
  revealed boolean not null default false,
  session_code text,
  participantes_esperados int,
  started_at timestamptz,
  constraint live_state_singleton check (id = 1)
);
insert into public.live_state (id) values (1) on conflict (id) do nothing;

create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  session_code text not null,
  round text not null,
  question_id int not null,
  participant_id uuid not null references public.participants(id) on delete cascade,
  option_index int not null,
  is_correct boolean not null,
  created_at timestamptz not null default now(),
  unique (session_code, question_id, participant_id)
);
create index if not exists answers_session_question_idx on public.answers (session_code, question_id);

-- Row Level Security: aberto para o anon (publishable key), sem login.
-- Trade-off consciente para um quiz de treinamento interno sem dados sensíveis:
-- qualquer pessoa com o link (ou a publishable key, que é pública por natureza)
-- pode ler e gravar nessas 3 tabelas. Não use este schema para dados sigilosos.

alter table public.participants enable row level security;
alter table public.live_state enable row level security;
alter table public.answers enable row level security;

drop policy if exists "public read participants" on public.participants;
create policy "public read participants" on public.participants for select using (true);
drop policy if exists "public upsert participants" on public.participants;
create policy "public upsert participants" on public.participants for insert with check (true);
drop policy if exists "public update participants" on public.participants;
create policy "public update participants" on public.participants for update using (true) with check (true);

drop policy if exists "public read live_state" on public.live_state;
create policy "public read live_state" on public.live_state for select using (true);
drop policy if exists "public update live_state" on public.live_state;
create policy "public update live_state" on public.live_state for update using (true) with check (true);

drop policy if exists "public read answers" on public.answers;
create policy "public read answers" on public.answers for select using (true);
drop policy if exists "public insert answers" on public.answers;
create policy "public insert answers" on public.answers for insert with check (true);
drop policy if exists "public update answers" on public.answers;
create policy "public update answers" on public.answers for update using (true) with check (true);

-- Realtime: liga o "ao vivo" (apresentador <-> celulares dos participantes)
alter publication supabase_realtime add table public.live_state;
alter publication supabase_realtime add table public.answers;

-- Consulta útil para exportar o resultado depois do treinamento (por pessoa):
-- select p.name, a.round, a.question_id, a.option_index, a.is_correct, a.created_at
-- from public.answers a join public.participants p on p.id = a.participant_id
-- order by p.name, a.round, a.question_id;
