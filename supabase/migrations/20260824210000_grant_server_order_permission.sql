-- Existing servers must receive the same default ability as newly-created
-- servers: submit orders through public.create_order.
INSERT INTO public.profile_permissions (profile_id, permission_id)
SELECT profile.id, permission.id
FROM public.profiles AS profile
CROSS JOIN public.permissions AS permission
WHERE profile.role = 'serveur'
  AND profile.is_active = true
  AND permission.code = 'create_order'
ON CONFLICT (profile_id, permission_id) DO NOTHING;
