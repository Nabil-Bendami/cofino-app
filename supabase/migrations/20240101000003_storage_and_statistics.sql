INSERT INTO storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
VALUES ('product-images', 'product-images', true, 5242880, ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO UPDATE SET public=EXCLUDED.public, file_size_limit=EXCLUDED.file_size_limit,
  allowed_mime_types=EXCLUDED.allowed_mime_types;

CREATE POLICY "Public can read product images" ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');
CREATE POLICY "Managers manage own cafe product images" ON storage.objects FOR ALL TO authenticated
USING (bucket_id='product-images' AND public.is_manager()
  AND (storage.foldername(name))[1]=public.get_current_cafe_id()::TEXT)
WITH CHECK (bucket_id='product-images' AND public.is_manager()
  AND (storage.foldername(name))[1]=public.get_current_cafe_id()::TEXT);

CREATE OR REPLACE FUNCTION public.mark_order_consulted(p_order_id UUID)
RETURNS public.orders LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE v_order public.orders;
BEGIN
  IF NOT public.is_manager() THEN RAISE EXCEPTION 'Manager requis' USING ERRCODE='42501'; END IF;
  UPDATE public.orders SET status='consultee', consulted_at=COALESCE(consulted_at,NOW()),
    consulted_by=COALESCE(consulted_by,auth.uid())
  WHERE id=p_order_id AND cafe_id=public.get_current_cafe_id() RETURNING * INTO v_order;
  IF NOT FOUND THEN RAISE EXCEPTION 'Commande introuvable'; END IF;
  RETURN v_order;
END; $$;

CREATE OR REPLACE FUNCTION public.get_order_statistics(p_from TIMESTAMPTZ,p_to TIMESTAMPTZ)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
DECLARE v_result JSONB;
BEGIN
  IF NOT public.is_manager() THEN RAISE EXCEPTION 'Manager requis' USING ERRCODE='42501'; END IF;
  SELECT jsonb_build_object('order_count',COUNT(*),'revenue',COALESCE(SUM(o.total),0),
    'top_products',COALESCE((SELECT jsonb_agg(x ORDER BY quantity DESC) FROM
      (SELECT oi.product_name_snapshot name,SUM(oi.quantity)::INT quantity
       FROM public.order_items oi JOIN public.orders xo ON xo.id=oi.order_id
       WHERE xo.cafe_id=public.get_current_cafe_id() AND xo.created_at>=p_from AND xo.created_at<p_to
       GROUP BY oi.product_name_snapshot ORDER BY SUM(oi.quantity) DESC LIMIT 10) x),'[]'::JSONB))
  INTO v_result FROM public.orders o
  WHERE o.cafe_id=public.get_current_cafe_id() AND o.created_at>=p_from AND o.created_at<p_to;
  RETURN v_result;
END; $$;

REVOKE ALL ON FUNCTION public.mark_order_consulted(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_order_statistics(TIMESTAMPTZ,TIMESTAMPTZ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.mark_order_consulted(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_order_statistics(TIMESTAMPTZ,TIMESTAMPTZ) TO authenticated;
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
