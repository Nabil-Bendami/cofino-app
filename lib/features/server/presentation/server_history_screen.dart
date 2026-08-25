import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/role_navigation.dart';

final serverHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getServerOrders();
});

class ServerHistoryScreen extends ConsumerWidget {
  const ServerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(serverHistoryProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      bottomNavigationBar: const ServerNavigation(index: 2),
      appBar: AppBar(
        title: const Text('Mes commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(serverHistoryProvider),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = (order['order_items'] as List);
              final status = order['status'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                    onTap: () => context.push('/server/order/${order['id']}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Commande #${order['order_number']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == 'nouvelle'
                                      ? AppTheme.caramel
                                      : AppTheme.dustyRose,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status == 'nouvelle'
                                      ? 'Nouvelle'
                                      : 'Consultée',
                                  style: const TextStyle(
                                      color: AppTheme.softWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateFormat
                                .format(DateTime.parse(order['created_at'])),
                            style: TextStyle(
                                color:
                                    AppTheme.darkBrown.withValues(alpha: 0.6)),
                          ),
                          const Divider(height: 24),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${item['quantity']}x ${item['product_name_snapshot']}'),
                                    Text(currencyFormat
                                        .format(item['subtotal'])),
                                  ],
                                ),
                              )),
                          if (order['note'] != null &&
                              order['note'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.cream,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Remarque: ${order['note']}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                currencyFormat.format(order['total']),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.coffee),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
