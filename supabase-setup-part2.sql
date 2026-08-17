-- Rode isso DEPOIS do supabase-setup.sql (SQL Editor > New Query > Run)

-- Tabela de perfis: nick, avatar, cores de fundo personalizadas
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  bg_color_1 text default '#120b26' not null,
  bg_color_2 text default '#5b8def' not null,
  updated_at timestamptz default now() not null
);

alter table public.profiles enable row level security;

-- Qualquer usuário logado pode ver perfil de outros (precisa pra mostrar nick/avatar no chat)
create policy "Perfis são visíveis para autenticados"
  on public.profiles for select
  to authenticated
  using (true);

-- Usuário só cria o PRÓPRIO perfil
create policy "Usuário cria seu próprio perfil"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Usuário só edita o PRÓPRIO perfil
create policy "Usuário edita seu próprio perfil"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Guarda nick e avatar junto de cada mensagem (evita join no realtime)
alter table public.messages add column avatar_url text;

-- Bucket público pra fotos de perfil
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Qualquer pessoa pode VER os avatares (bucket público)
create policy "Avatares são públicos para leitura"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- Usuário só pode enviar arquivo dentro da SUA PRÓPRIA pasta (avatars/{user_id}/...)
create policy "Usuário envia seu próprio avatar"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- Usuário só pode substituir arquivo dentro da SUA PRÓPRIA pasta
create policy "Usuário atualiza seu próprio avatar"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
