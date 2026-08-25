import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/manager_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/role_navigation.dart';

class ManagerHistoryScreen extends ConsumerStatefulWidget {
  const ManagerHistoryScreen({super.key});
  @override
  ConsumerState<ManagerHistoryScreen> createState() =>
      _ManagerHistoryScreenState();
}

class _ManagerHistoryScreenState extends ConsumerState<ManagerHistoryScreen> {
  String query = '';
  String? status;
  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(managerOrdersProvider);
    final money = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
    return Scaffold(
        bottomNavigationBar: const ManagerNavigation(index: 1),
        appBar: AppBar(title: const Text('Historique'), actions: [
          IconButton(
              onPressed: () => ref.invalidate(managerOrdersProvider),
              icon: const Icon(Icons.refresh))
        ]),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'N° ou serveur'),
                        onChanged: (v) =>
                            setState(() => query = v.toLowerCase()))),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                    value: status,
                    hint: const Text('État'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tous')),
                      DropdownMenuItem(
                          value: 'nouvelle', child: Text('Nouvelle')),
                      DropdownMenuItem(
                          value: 'consultee', child: Text('Consultée'))
                    ],
                    onChanged: (v) => setState(() => status = v))
              ])),
          Expanded(
              child: orders.when(
                  data: (rows) {
                    final filtered = rows.where((o) {
                      final server = o['profiles']?['full_name']
                              ?.toString()
                              .toLowerCase() ??
                          '';
                      return (status == null || o['status'] == status) &&
                          ('${o['order_number']}'.contains(query) ||
                              server.contains(query));
                    }).toList();
                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('Aucune commande trouvée.'));
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final o = filtered[i];
                          return Card(
                              child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundColor: AppTheme.lightBeige,
                                      child: Text('#${o['order_number']}')),
                                  title: Text(
                                      o['profiles']?['full_name'] ?? 'Serveur'),
                                  subtitle: Text(
                                      DateFormat('dd/MM/yyyy HH:mm', 'fr_MA')
                                          .format(
                                              DateTime.parse(o['created_at'])
                                                  .toLocal())),
                                  trailing: Text(money.format(o['total']),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => context
                                      .push('/manager/order/${o['id']}')));
                        });
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Error(
                      message: '$e',
                      retry: () => ref.invalidate(managerOrdersProvider))))
        ]));
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Impossible de charger l’historique\n$message',
            textAlign: TextAlign.center),
        TextButton(onPressed: retry, child: const Text('Réessayer'))
      ]));
}
