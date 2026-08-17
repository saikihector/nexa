-- Rode isso DEPOIS do supabase-setup-part3.sql (SQL Editor > New Query > Run)

-- Permite mensagem só com mídia (sem texto)
alter table public.messages alter column content drop not null;

-- Novas colunas pra anexo
alter table public.messages add column media_url text;
alter table public.messages add column media_type text check (media_type in ('image', 'video'));

-- Garante que a mensagem tenha pelo menos texto OU mídia
alter table public.messages add constraint messages_has_content
  check (content is not null or media_url is not null);

-- Bucket público pra imagens/vídeos enviados no chat
insert into storage.buckets (id, name, public, file_size_limit)
values ('chat-media', 'chat-media', true, 26214400) -- 25MB
on conflict (id) do nothing;

create policy "Mídia do chat é pública para leitura"
  on storage.objects for select
  using (bucket_id = 'chat-media');

create policy "Usuário envia mídia na própria pasta"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'chat-media' and (storage.foldername(name))[1] = auth.uid()::text);
