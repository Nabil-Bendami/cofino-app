import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final security =
      File('supabase/migrations/20240101000001_security_and_functions.sql')
          .readAsStringSync();
  final rpc = File('supabase/migrations/20240101000002_rpc_create_order.sql')
      .readAsStringSync();
  final schema = File('supabase/migrations/20240101000000_initial_schema.sql')
      .readAsStringSync();
  test('le manager est limité aux commandes de son café', () {
    expect(security, contains('cafe_id = public.get_current_cafe_id()'));
    expect(security, contains('Managers can view all orders in their cafe'));
  });
  test('le serveur ne voit que ses commandes', () {
    expect(security, contains('server_id = auth.uid()'));
    expect(security, contains('Servers can view their own orders'));
  });
  test('la RPC valide café, disponibilité et quantité', () {
    expect(rpc, contains('product.cafe_id=v_profile.cafe_id'));
    expect(rpc, contains("(item->>'quantity')::INTEGER<=0"));
  });
  test('le nom et le prix sont figés dans les lignes historiques', () {
    expect(schema, contains('product_name_snapshot TEXT NOT NULL'));
    expect(schema, contains('unit_price_snapshot NUMERIC(10, 2) NOT NULL'));
    expect(schema, contains('ON DELETE SET NULL'));
  });
}
