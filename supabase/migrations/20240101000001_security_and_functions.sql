-- 20240101000001_security_and_functions.sql

-- Enable RLS on all tables
ALTER TABLE public.cafes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Helper Functions
CREATE OR REPLACE FUNCTION public.get_current_profile()
RETURNS public.profiles
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT * FROM profiles WHERE id = auth.uid() AND is_active = true LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.get_current_cafe_id()
RETURNS UUID
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT cafe_id FROM profiles WHERE id = auth.uid() AND is_active = true LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.is_manager()
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role = 'manager' 
    AND is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION public.is_active_server()
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role = 'serveur' 
    AND is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION public.has_permission(permission_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profile_permissions pp
    JOIN permissions p ON pp.permission_id = p.id
    JOIN profiles profile ON profile.id = pp.profile_id
    WHERE pp.profile_id = auth.uid()
    AND profile.is_active = true
    AND profile.role = 'serveur'
    AND p.code = permission_code
  );
$$;

-- RLS Policies

-- Cafes: Users can only see their own cafe
CREATE POLICY "Users can view their own cafe" 
ON public.cafes FOR SELECT 
TO authenticated 
USING (id = public.get_current_cafe_id());

-- Profiles: Users can see profiles in their own cafe. Managers can insert/update.
CREATE POLICY "Users can view profiles in their cafe" 
ON public.profiles FOR SELECT 
TO authenticated 
USING (
  cafe_id = public.get_current_cafe_id()
  AND (public.is_manager() OR id = auth.uid())
);

-- Account creation/deactivation is handled by the authenticated manage-server
-- Edge Function; clients cannot mutate profile roles or cafe ownership directly.

-- Permissions: All authenticated users can view permissions
CREATE POLICY "Authenticated users can view permissions" 
ON public.permissions FOR SELECT 
TO authenticated 
USING (public.get_current_cafe_id() IS NOT NULL);

-- Profile Permissions: Users can see profile permissions in their cafe. Managers can manage.
CREATE POLICY "Users can view profile permissions in their cafe"
ON public.profile_permissions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles p 
    WHERE p.id = profile_permissions.profile_id 
    AND p.cafe_id = public.get_current_cafe_id()
    AND (public.is_manager() OR p.id = auth.uid())
  )
);

CREATE POLICY "Managers can manage profile permissions in their cafe"
ON public.profile_permissions FOR ALL
TO authenticated
USING (
  public.is_manager() AND EXISTS (
    SELECT 1 FROM profiles p 
    WHERE p.id = profile_permissions.profile_id 
    AND p.cafe_id = public.get_current_cafe_id()
    AND p.role = 'serveur'
  )
)
WITH CHECK (
  public.is_manager() AND EXISTS (
    SELECT 1 FROM profiles p 
    WHERE p.id = profile_permissions.profile_id 
    AND p.cafe_id = public.get_current_cafe_id()
    AND p.role = 'serveur'
  )
);

-- Categories: Anyone in the cafe can read. Managers can manage.
CREATE POLICY "Users can view categories in their cafe" 
ON public.categories FOR SELECT 
TO authenticated 
USING (cafe_id = public.get_current_cafe_id());

CREATE POLICY "Managers can manage categories in their cafe" 
ON public.categories FOR ALL 
TO authenticated 
USING (public.is_manager() AND cafe_id = public.get_current_cafe_id())
WITH CHECK (public.is_manager() AND cafe_id = public.get_current_cafe_id());

-- Managers see all products; active servers only see active products.
CREATE POLICY "Users can view products in their cafe" 
ON public.products FOR SELECT 
TO authenticated 
USING (
  cafe_id = public.get_current_cafe_id()
  AND (public.is_manager() OR (public.is_active_server() AND is_active = true))
);

CREATE POLICY "Managers can manage products in their cafe" 
ON public.products FOR ALL 
TO authenticated 
USING (public.is_manager() AND cafe_id = public.get_current_cafe_id())
WITH CHECK (public.is_manager() AND cafe_id = public.get_current_cafe_id());

-- Orders: Managers see all in their cafe. Servers see only their own.
CREATE POLICY "Managers can view all orders in their cafe" 
ON public.orders FOR SELECT 
TO authenticated 
USING (public.is_manager() AND cafe_id = public.get_current_cafe_id());

CREATE POLICY "Servers can view their own orders" 
ON public.orders FOR SELECT 
TO authenticated 
USING (public.is_active_server() AND server_id = auth.uid() AND cafe_id = public.get_current_cafe_id());

CREATE POLICY "Managers can update orders in their cafe" 
ON public.orders FOR UPDATE 
TO authenticated 
USING (public.is_manager() AND cafe_id = public.get_current_cafe_id())
WITH CHECK (public.is_manager() AND cafe_id = public.get_current_cafe_id());

-- Order Items: Managers see all in their cafe. Servers see their own.
CREATE POLICY "Managers can view all order items in their cafe" 
ON public.order_items FOR SELECT 
TO authenticated 
USING (
  public.is_manager() AND EXISTS (
    SELECT 1 FROM orders o WHERE o.id = order_items.order_id AND o.cafe_id = public.get_current_cafe_id()
  )
);

CREATE POLICY "Servers can view their own order items" 
ON public.order_items FOR SELECT 
TO authenticated 
USING (
  public.is_active_server() AND EXISTS (
    SELECT 1 FROM orders o WHERE o.id = order_items.order_id AND o.server_id = auth.uid() AND o.cafe_id = public.get_current_cafe_id()
  )
);

-- Order inserts are intentionally restricted to the SECURITY DEFINER RPC.

REVOKE ALL ON FUNCTION public.get_current_profile() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_current_cafe_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_manager() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_active_server() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.has_permission(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_current_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_current_cafe_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_manager() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_active_server() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_permission(TEXT) TO authenticated;
