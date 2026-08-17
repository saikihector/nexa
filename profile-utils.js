// Busca o perfil do usuário. Se ainda não existir (ex: conta criada antes
// dessa feature existir), cria um na hora com valores padrão.
async function ensureProfile(user) {
  const { data: existing } = await client
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  if (existing) return existing;

  const username = user.user_metadata?.username || user.email.split("@")[0];

  const { data: created, error } = await client
    .from("profiles")
    .insert({ id: user.id, username })
    .select()
    .single();

  if (error) {
    // Corrida rara (duas abas abrindo ao mesmo tempo) — tenta buscar de novo
    const { data: retry } = await client.from("profiles").select("*").eq("id", user.id).single();
    return retry;
  }

  return created;
}

// Aplica as cores de fundo salvas do usuário nas variáveis CSS globais
function applyUserBackground(profile) {
  if (!profile) return;
  document.documentElement.style.setProperty("--bg-1", profile.bg_color_1);
  document.documentElement.style.setProperty("--bg-2", profile.bg_color_1);
  document.documentElement.style.setProperty("--bg-3", profile.bg_color_2);
}
