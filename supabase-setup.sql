-- Rode isso no painel Supabase: SQL Editor > New Query > Run

-- Tabela de mensagens do chat
create table public.messages (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  username text not null,
  content text not null check (char_length(content) between 1 and 500),
  created_at timestamptz default now() not null
);

-- Ativa Row Level Security
alter table public.messages enable row level security;

-- Qualquer usuário logado pode ler as mensagens
create policy "Usuários autenticados podem ler mensagens"
  on public.messages for select
  to authenticated
  using (true);

-- Usuário só pode inserir mensagem com o próprio user_id
create policy "Usuários podem enviar suas próprias mensagens"
  on public.messages for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Habilita realtime pra essa tabela (necessário pra insert aparecer ao vivo)
alter publication supabase_realtime add table public.messages;
