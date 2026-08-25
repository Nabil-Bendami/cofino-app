import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/manager_provider.dart';

final orderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getManagerOrder(id);
});

class ManagerOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const ManagerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la commande')),
      body: orderAsync.when(
        data: (order) {
          final items = (order['order_items'] as List);
          final serverName = order['profiles'] != null
              ? order['profiles']['full_name']
              : 'Inconnu';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Commande #${order['order_number']}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Serveur: $serverName',
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        'Date: ${dateFormat.format(DateTime.parse(order['created_at']))}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    const Text('Produits',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['product_name_snapshot'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${item['quantity']} x ${currencyFormat.format(item['unit_price_snapshot'])}'),
                                  ],
                                ),
                              ),
                              Text(currencyFormat.format(item['subtotal']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const Divider(),
                    if (order['note'] != null &&
                        order['note'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Remarque',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(order['note'],
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(currencyFormat.format(order['total']),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.coffee)),
                      ],
                    ),
                  ],
                ),
              ),
              if (order['status'] == 'nouvelle')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(orderRepositoryProvider)
                          .markOrderAsConsulted(orderId);
                      ref.invalidate(orderDetailProvider(orderId));
                      ref.invalidate(newOrdersProvider);
                      ref.invalidate(managerOrdersProvider);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Marquer comme consultée',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
