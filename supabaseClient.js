// ⚠️ Preencha com os dados do SEU projeto Supabase
// Painel Supabase > Project Settings > API
const SUPABASE_URL = "https://wcjiqfmmegsnvdumjqoo.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_gG-B7ECyr-9A2n3f1Sz8rw_Dhcv0R3x";

// O objeto global `supabase` vem do script CDN incluído no <head> de cada página
const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Redireciona para login se não estiver autenticado (usar nas páginas protegidas)
async function requireAuth() {
  const { data: { session } } = await client.auth.getSession();
  if (!session) {
    window.location.href = "login.html";
    return null;
  }
  return session;
}
