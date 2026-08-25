import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_service.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  static const detailSelect =
      '*, order_items(*), profiles!orders_server_id_fkey(full_name)';
  Future<List<Map<String, dynamic>>> getServerOrders() async =>
      List<Map<String, dynamic>>.from(await SupabaseService.client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false));
  Future<Map<String, dynamic>> getServerOrder(String id) async =>
      Map<String, dynamic>.from(await SupabaseService.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', id)
          .single());
  Future<List<Map<String, dynamic>>> getManagerOrders(
      {bool newOnly = false}) async {
    var query = SupabaseService.client.from('orders').select(detailSelect);
    if (newOnly) query = query.eq('status', 'nouvelle');
    return List<Map<String, dynamic>>.from(
        await query.order('created_at', ascending: false));
  }

  Future<Map<String, dynamic>> getManagerOrder(String id) async =>
      Map<String, dynamic>.from(await SupabaseService.client
          .from('orders')
          .select(detailSelect)
          .eq('id', id)
          .single());
  Future<Map<String, dynamic>> createOrder(
          {required List<Map<String, dynamic>> items,
          required String requestId,
          String? note}) async =>
      Map<String, dynamic>.from(await SupabaseService.client.rpc('create_order',
          params: {
            'p_items': items,
            'p_note': note,
            'p_request_id': requestId
          }));
  Future<void> markOrderAsConsulted(String id) async => SupabaseService.client
      .rpc('mark_order_consulted', params: {'p_order_id': id});
  Stream<List<Map<String, dynamic>>> watchNewOrders() => SupabaseService.client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('status', 'nouvelle')
      .order('created_at', ascending: false);
  Future<Map<String, dynamic>> statistics(DateTime from, DateTime to) async =>
      Map<String, dynamic>.from(await SupabaseService.client
          .rpc('get_order_statistics', params: {
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String()
      }));
}
