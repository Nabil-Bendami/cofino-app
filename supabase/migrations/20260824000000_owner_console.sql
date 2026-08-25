-- Secure read and administration surface for the Cofino Owner console.
-- A platform owner must be explicitly added to public.platform_owners after
-- creating their Supabase Auth user. See cofino-owner/README.md.

CREATE TABLE IF NOT EXISTS public.platform_owners (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.platform_owners ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Owners can read their own grant" ON public.platform_owners;
CREATE POLICY "Owners can read their own grant"
ON public.platform_owners FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.is_platform_owner()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.platform_owners WHERE user_id = auth.uid());
$$;

REVOKE ALL ON FUNCTION public.is_platform_owner() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_platform_owner() TO authenticated;

DROP POLICY IF EXISTS "Platform owners can view all cafes" ON public.cafes;
CREATE POLICY "Platform owners can view all cafes"
ON public.cafes FOR SELECT TO authenticated
USING (public.is_platform_owner());

DROP POLICY IF EXISTS "Platform owners can view all profiles" ON public.profiles;
CREATE POLICY "Platform owners can view all profiles"
ON public.profiles FOR SELECT TO authenticated
USING (public.is_platform_owner());

DROP POLICY IF EXISTS "Platform owners can view all orders" ON public.orders;
CREATE POLICY "Platform owners can view all orders"
ON public.orders FOR SELECT TO authenticated
USING (public.is_platform_owner());

CREATE TABLE IF NOT EXISTS public.cafe_subscriptions (
  cafe_id UUID PRIMARY KEY REFERENCES public.cafes(id) ON DELETE CASCADE,
  plan TEXT NOT NULL CHECK (plan IN ('starter', 'pro', 'business')),
  status TEXT NOT NULL DEFAULT 'trial' CHECK (status IN ('trial', 'active', 'suspended')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.cafe_subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Platform owners can view subscriptions" ON public.cafe_subscriptions;
CREATE POLICY "Platform owners can view subscriptions"
ON public.cafe_subscriptions FOR SELECT TO authenticated
USING (public.is_platform_owner());

DROP TRIGGER IF EXISTS cafe_subscriptions_set_updated_at ON public.cafe_subscriptions;
CREATE TRIGGER cafe_subscriptions_set_updated_at BEFORE UPDATE ON public.cafe_subscriptions
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.owner_set_cafe_access(p_cafe_id UUID, p_is_active BOOLEAN)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF NOT public.is_platform_owner() THEN
    RAISE EXCEPTION 'Accès propriétaire requis' USING ERRCODE = '42501';
  END IF;

  UPDATE public.profiles
  SET is_active = p_is_active
  WHERE cafe_id = p_cafe_id;
END;
$$;

REVOKE ALL ON FUNCTION public.owner_set_cafe_access(UUID, BOOLEAN) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.owner_set_cafe_access(UUID, BOOLEAN) TO authenticated;
