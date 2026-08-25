CREATE OR REPLACE FUNCTION public.create_order(p_items JSONB,p_note TEXT,p_request_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE
  v_profile public.profiles%ROWTYPE;
  v_order public.orders%ROWTYPE;
  v_total NUMERIC(10,2):=0;
  v_requested_count INTEGER;
  v_valid_count INTEGER;
BEGIN
  SELECT * INTO v_profile FROM public.profiles
  WHERE id=auth.uid() AND role='serveur' AND is_active=true;
  IF NOT FOUND THEN RAISE EXCEPTION 'Serveur actif requis' USING ERRCODE='42501'; END IF;
  IF NOT public.has_permission('create_order') THEN
    RAISE EXCEPTION 'Permission create_order requise' USING ERRCODE='42501';
  END IF;
  IF p_request_id IS NULL THEN RAISE EXCEPTION 'Identifiant de requête requis'; END IF;

  SELECT * INTO v_order FROM public.orders
  WHERE server_id=v_profile.id AND client_request_id=p_request_id;
  IF FOUND THEN RETURN to_jsonb(v_order); END IF;

  IF p_items IS NULL OR jsonb_typeof(p_items)<>'array' OR jsonb_array_length(p_items)=0 THEN
    RAISE EXCEPTION 'La commande doit contenir au moins un produit';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(p_items) item
    WHERE (item->>'quantity')::INTEGER IS NULL OR (item->>'quantity')::INTEGER<=0
  ) THEN RAISE EXCEPTION 'Quantité invalide'; END IF;

  PERFORM product.id
  FROM public.products product
  JOIN jsonb_array_elements(p_items) item
    ON product.id=(item->>'product_id')::UUID
  FOR SHARE OF product;

  WITH requested AS (
    SELECT (item->>'product_id')::UUID product_id,
      SUM((item->>'quantity')::INTEGER)::INTEGER quantity
    FROM jsonb_array_elements(p_items) item
    GROUP BY (item->>'product_id')::UUID
  )
  SELECT COUNT(*),COUNT(product.id),
    COALESCE(SUM(ROUND(product.price*requested.quantity,2)),0)
  INTO v_requested_count,v_valid_count,v_total
  FROM requested
  LEFT JOIN public.products product
    ON product.id=requested.product_id
    AND product.cafe_id=v_profile.cafe_id
    AND product.is_active=true;

  IF v_requested_count<>v_valid_count THEN
    RAISE EXCEPTION 'Produit indisponible ou étranger au café';
  END IF;

  INSERT INTO public.orders(cafe_id,server_id,client_request_id,note,total)
  VALUES(v_profile.cafe_id,v_profile.id,p_request_id,NULLIF(BTRIM(p_note),''),v_total)
  RETURNING * INTO v_order;

  INSERT INTO public.order_items(
    order_id,product_id,product_name_snapshot,unit_price_snapshot,quantity,subtotal
  )
  SELECT v_order.id,product.id,product.name,product.price,requested.quantity,
    ROUND(product.price*requested.quantity,2)
  FROM (
    SELECT (item->>'product_id')::UUID product_id,
      SUM((item->>'quantity')::INTEGER)::INTEGER quantity
    FROM jsonb_array_elements(p_items) item
    GROUP BY (item->>'product_id')::UUID
  ) requested
  JOIN public.products product ON product.id=requested.product_id;

  RETURN to_jsonb(v_order);
EXCEPTION WHEN unique_violation THEN
  SELECT * INTO v_order FROM public.orders
  WHERE server_id=auth.uid() AND client_request_id=p_request_id;
  IF FOUND THEN RETURN to_jsonb(v_order); END IF;
  RAISE;
END; $$;
REVOKE ALL ON FUNCTION public.create_order(JSONB,TEXT,UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_order(JSONB,TEXT,UUID) TO authenticated;

