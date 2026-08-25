import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/order_repository.dart';

final serverOrderProvider = FutureProvider.family<Map<String, dynamic>, String>(
    (ref, id) => ref.watch(orderRepositoryProvider).getServerOrder(id));

class ServerOrderDetailScreen extends ConsumerWidget {
  const ServerOrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(serverOrderProvider(orderId));
    final money = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
    return Scaffold(
        appBar: AppBar(title: const Text('Détail de la commande')),
        body: order.when(
            data: (o) => ListView(padding: const EdgeInsets.all(20), children: [
                  Text('Commande #${o['order_number']}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(DateFormat('dd/MM/yyyy HH:mm', 'fr_MA')
                      .format(DateTime.parse(o['created_at']).toLocal())),
                  const Divider(height: 32),
                  ...List<Map<String, dynamic>>.from(o['order_items']).map(
                      (i) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(i['product_name_snapshot']),
                          subtitle: Text(
                              '${i['quantity']} × ${money.format(i['unit_price_snapshot'])}'),
                          trailing: Text(money.format(i['subtotal'])))),
                  if (o['note']?.toString().isNotEmpty == true)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text('Remarque : ${o['note']}'))),
                  const Divider(),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text('Total : ${money.format(o['total'])}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)))
                ]),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur : $e'))));
  }
}
