-- Owner-controlled subscription state.  "active" is the platform's manually
-- recorded paid state until a payment provider is integrated.
CREATE OR REPLACE FUNCTION public.owner_set_subscription_status(
  p_cafe_id UUID,
  p_status TEXT
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF NOT public.is_platform_owner() THEN
    RAISE EXCEPTION 'Accès propriétaire requis' USING ERRCODE = '42501';
  END IF;

  IF p_status NOT IN ('trial', 'active', 'suspended') THEN
    RAISE EXCEPTION 'Statut d’abonnement invalide' USING ERRCODE = '22023';
  END IF;

  UPDATE public.cafe_subscriptions
  SET status = p_status
  WHERE cafe_id = p_cafe_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Aucun abonnement configuré pour ce café' USING ERRCODE = 'P0002';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.owner_set_subscription_status(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.owner_set_subscription_status(UUID, TEXT) TO authenticated;
