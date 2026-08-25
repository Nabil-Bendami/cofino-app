import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

type CreateCafeBody = {
  action: 'create_cafe'
  cafeName: string
  ownerName: string
  email: string
  password: string
  city: string
  plan: 'Starter' | 'Pro' | 'Business'
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const url = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const authorization = request.headers.get('Authorization') ?? ''
    const caller = createClient(url, anonKey, { global: { headers: { Authorization: authorization } } })
    const admin = createClient(url, serviceRoleKey)
    const { data: { user }, error: userError } = await caller.auth.getUser()

    if (userError || !user) return json({ error: 'Authentification requise.' }, 401)

    const { data: owner } = await admin
      .from('platform_owners')
      .select('user_id')
      .eq('user_id', user.id)
      .maybeSingle()
    if (!owner) return json({ error: 'Accès propriétaire requis.' }, 403)

    const body = await request.json() as CreateCafeBody
    if (body.action !== 'create_cafe') return json({ error: 'Action non prise en charge.' }, 400)
    if (!validInput(body)) return json({ error: 'Les informations du café sont incomplètes ou invalides.' }, 400)

    const { data: cafe, error: cafeError } = await admin
      .from('cafes')
      .insert({ name: body.cafeName.trim(), city: body.city.trim() })
      .select('id,name,city')
      .single()
    if (cafeError || !cafe) throw cafeError ?? new Error('Création du café impossible.')

    const { data: manager, error: managerError } = await admin.auth.admin.createUser({
      email: body.email.trim(),
      password: body.password,
      email_confirm: true,
      user_metadata: { full_name: body.ownerName.trim() },
    })
    if (managerError || !manager.user) {
      await admin.from('cafes').delete().eq('id', cafe.id)
      if (managerError?.message.toLowerCase().includes('already')) {
        return json({ error: 'Cet e-mail est déjà associé à un compte manager. Utilisez une autre adresse e-mail.' }, 409)
      }
      throw managerError ?? new Error('Création du gérant impossible.')
    }

    const { error: subscriptionError } = await admin.from('cafe_subscriptions').insert({
      cafe_id: cafe.id,
      plan: body.plan.toLowerCase(),
      status: 'trial',
    })
    if (subscriptionError) {
      await admin.from('cafes').delete().eq('id', cafe.id)
      throw subscriptionError
    }

    const { error: profileError } = await admin.from('profiles').insert({
      id: manager.user.id,
      cafe_id: cafe.id,
      full_name: body.ownerName.trim(),
      email: body.email.trim(),
      role: 'manager',
      is_active: true,
    })
    if (profileError) {
      await admin.from('cafes').delete().eq('id', cafe.id)
      throw profileError
    }

    return json({ cafe }, 201)
  } catch (error) {
    console.error(error)
    return json({ error: error instanceof Error ? error.message : 'Erreur interne.' }, 500)
  }
})

function validInput(body: CreateCafeBody) {
  return typeof body.cafeName === 'string' && body.cafeName.trim().length > 1
    && typeof body.ownerName === 'string' && body.ownerName.trim().length > 1
    && typeof body.city === 'string' && body.city.trim().length > 1
    && typeof body.email === 'string' && /^\S+@\S+\.\S+$/.test(body.email)
    && typeof body.password === 'string' && body.password.length >= 8
    && ['Starter', 'Pro', 'Business'].includes(body.plan)
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
