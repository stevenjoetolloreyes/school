
function supaConfigured() {
  return window.SUPABASE_URL && window.SUPABASE_URL.indexOf('YOUR_') !== 0 &&
    window.SUPABASE_ANON_KEY && window.SUPABASE_ANON_KEY.indexOf('YOUR_') !== 0;
}
function supa() {
  if (!supaConfigured()) return null;
  if (!window._supa) window._supa = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
  return window._supa;
}
function todayLocal() {
  var d = new Date();
  return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
}
function showMsg(id, text, ok) {
  var el = document.getElementById(id);
  if (!el) return;
  el.style.display = 'block';
  el.style.color = ok ? '#16a34a' : '#dc2626';
  el.textContent = text;
}
async function getProfile(client) {
  var u = (await client.auth.getUser()).data.user;
  if (!u) return null;
  var r = await client.from('profiles').select('*').eq('id', u.id).single();
  if (r.data) return r.data;
  return { id: u.id, email: u.email, role: null, student_id: null };
}
async function requireRole(role) {
  var c = supa();
  if (!c) {
    document.body.innerHTML = '<div style="padding:40px;font-family:sans-serif;line-height:1.6">'
      + '<h2>Supabase is not configured yet</h2>'
      + '<p>Fill in <b>config.js</b> with the Supabase Project URL and anon key, then reload.</p></div>';
    throw new Error('not configured');
  }
  var s = await c.auth.getSession();
  if (!s.data.session) { window.location.href = '/'; throw new Error('no session'); }
  var p = await getProfile(c);
  if (p.role !== role) {
    window.location.href = p.role === 'teacher' ? '/teacher' : '/student';
    throw new Error('wrong role');
  }
  return { client: c, profile: p };
}
async function signOutGo() {
  var c = supa();
  if (c) await c.auth.signOut();
  window.location.href = '/';
}
function bindLogout() {
  var el = document.getElementById('logoutLink');
  if (el) el.addEventListener('click', function (e) { e.preventDefault(); signOutGo(); });
}
