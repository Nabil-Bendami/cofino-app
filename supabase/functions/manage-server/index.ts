import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  try {
    const url = Deno.env.get('SUPABASE_URL')!
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const authHeader = request.headers.get('Authorization') ?? ''
    const caller = createClient(url, anon, { global: { headers: { Authorization: authHeader } } })
    const admin = createClient(url, service)
    const { data: { user } } = await caller.auth.getUser()
    if (!user) return json({ error: 'Non authentifié' }, 401)
    const { data: manager } = await admin.from('profiles').select('cafe_id,role,is_active').eq('id', user.id).single()
    if (!manager?.is_active || manager.role !== 'manager') return json({ error: 'Manager requis' }, 403)
    const body = await request.json()
    if (body.action === 'create') {
      const { data, error } = await admin.auth.admin.createUser({ email: body.email, password: body.password,
        email_confirm: true, user_metadata: { full_name: body.full_name } })
      if (error) return json({ error: error.message }, 400)
      const { error: profileError } = await admin.from('profiles').insert({ id: data.user.id,
        cafe_id: manager.cafe_id, full_name: body.full_name, email: body.email, role: 'serveur', is_active: true })
      if (profileError) { await admin.auth.admin.deleteUser(data.user.id); return json({ error: profileError.message }, 400) }

      // A newly-created server must be able to submit an order immediately.
      const { data: createOrderPermission, error: permissionError } = await admin
        .from('permissions')
        .select('id')
        .eq('code', 'create_order')
        .single()
      if (permissionError || !createOrderPermission) {
        await admin.from('profiles').delete().eq('id', data.user.id)
        await admin.auth.admin.deleteUser(data.user.id)
        return json({ error: 'Permission create_order introuvable.' }, 500)
      }
      const { error: grantError } = await admin.from('profile_permissions').insert({
        profile_id: data.user.id,
        permission_id: createOrderPermission.id,
      })
      if (grantError) {
        await admin.from('profiles').delete().eq('id', data.user.id)
        await admin.auth.admin.deleteUser(data.user.id)
        return json({ error: grantError.message }, 500)
      }
      return json({ id: data.user.id })
    }
    if (body.action === 'update') {
      const { error } = await admin.from('profiles').update({ full_name: body.full_name,
        is_active: body.is_active }).eq('id', body.profile_id).eq('cafe_id', manager.cafe_id).eq('role', 'serveur')
      if (error) return json({ error: error.message }, 400)
      return json({ ok: true })
    }
    return json({ error: 'Action invalide' }, 400)
  } catch (error) {
    console.error(error)
    return json({ error: error instanceof Error ? error.message : 'Erreur interne.' }, 500)
  }
})
