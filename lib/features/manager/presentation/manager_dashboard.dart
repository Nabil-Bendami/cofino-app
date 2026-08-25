import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/manager_provider.dart';
import '../../../core/widgets/role_navigation.dart';

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newOrdersAsync = ref.watch(newOrdersProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final stats = ref.watch(statisticsProvider(StatsPeriod.day)).valueOrNull;
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelles commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour ${profile?.fullName ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(profile?.cafeName ?? 'Votre café'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _Metric(
                              label: 'Commandes',
                              value: '${stats?['order_count'] ?? 0}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _Metric(
                              label: 'Revenu du jour',
                              value: currencyFormat
                                  .format(stats?['revenue'] ?? 0)))
                    ])
                  ],
                )),
          ),
          _buildQuickActions(context),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Nouvelles commandes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: newOrdersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('Aucune nouvelle commande.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side:
                            const BorderSide(color: AppTheme.caramel, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.caramel,
                          child: Icon(Icons.notifications_active,
                              color: AppTheme.softWhite),
                        ),
                        title: Text('Commande #${order['order_number']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(currencyFormat.format(order['total'])),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/manager/order/${order['id']}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ManagerNavigation(index: 0),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Icons.add_circle,
            label: 'Gérer le menu',
            onTap: () => context.push('/manager/menu'),
          ),
          _QuickAction(
            icon: Icons.person_add,
            label: 'Ajouter Serveur',
            onTap: () => context.push('/manager/team'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.softWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBrown.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.coffee),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.coffee))
          ])));
}
