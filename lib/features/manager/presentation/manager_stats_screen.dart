import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/manager_provider.dart';
import '../../../core/widgets/role_navigation.dart';

class ManagerStatsScreen extends ConsumerStatefulWidget {
  const ManagerStatsScreen({super.key});
  @override
  ConsumerState<ManagerStatsScreen> createState() => _ManagerStatsScreenState();
}

class _ManagerStatsScreenState extends ConsumerState<ManagerStatsScreen> {
  StatsPeriod period = StatsPeriod.day;
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statisticsProvider(period));
    return Scaffold(
        bottomNavigationBar: const ManagerNavigation(index: 3),
        appBar: AppBar(title: const Text('Statistiques'), actions: [
          IconButton(
              tooltip: 'Actualiser',
              onPressed: () => ref.invalidate(statisticsProvider(period)),
              icon: const Icon(Icons.refresh))
        ]),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<StatsPeriod>(
                  segments: const [
                    ButtonSegment(value: StatsPeriod.day, label: Text('Jour')),
                    ButtonSegment(
                        value: StatsPeriod.week, label: Text('Semaine')),
                    ButtonSegment(value: StatsPeriod.month, label: Text('Mois'))
                  ],
                  selected: {
                    period
                  },
                  onSelectionChanged: (v) {
                    final selectedPeriod = v.first;
                    ref.invalidate(statisticsProvider(selectedPeriod));
                    setState(() => period = selectedPeriod);
                  })),
          Expanded(
              child: stats.when(
                  data: (data) {
                    final orderCount =
                        (data['order_count'] as num? ?? 0).toInt();
                    final revenue = (data['revenue'] as num? ?? 0).toDouble();
                    final top = List<Map<String, dynamic>>.from(
                        data['top_products'] ?? []);
                    final max = top.fold<double>(
                        1,
                        (m, e) => (e['quantity'] as num).toDouble() > m
                            ? (e['quantity'] as num).toDouble()
                            : m);
                    return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          Text(_periodTitle(period),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(_periodRange(period),
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Commandes', value: '$orderCount')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    label: 'CA de la période',
                                    value: NumberFormat.currency(
                                            locale: 'fr_MA', symbol: 'MAD')
                                        .format(revenue)))
                          ]),
                          const SizedBox(height: 24),
                          if (orderCount == 0)
                            _EmptyPeriodCard(period: period)
                          else ...[
                            Text('Produits les plus commandés',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            if (top.isNotEmpty)
                              SizedBox(
                                  height: 210,
                                  child: BarChart(BarChartData(
                                      maxY: max + 1,
                                      gridData: const FlGridData(show: false),
                                      titlesData: const FlTitlesData(
                                          leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30)),
                                          rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false))),
                                      barGroups: [
                                        for (var i = 0; i < top.length; i++)
                                          BarChartGroupData(x: i, barRods: [
                                            BarChartRodData(
                                                toY: (top[i]['quantity'] as num)
                                                    .toDouble(),
                                                color: AppTheme.caramel,
                                                width: 18,
                                                borderRadius:
                                                    BorderRadius.circular(6))
                                          ])
                                      ]))),
                            ...top.asMap().entries.map((e) => ListTile(
                                leading:
                                    CircleAvatar(child: Text('${e.key + 1}')),
                                title: Text(e.value['name']),
                                trailing: Text(
                                    '${e.value['quantity']} commandé(s)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))))
                          ]
                        ]);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Statistiques indisponibles\n$e',
                            textAlign: TextAlign.center),
                        TextButton(
                            onPressed: () =>
                                ref.invalidate(statisticsProvider(period)),
                            child: const Text('Réessayer'))
                      ]))))
        ]));
  }
}

String _periodTitle(StatsPeriod period) => switch (period) {
      StatsPeriod.day => 'Résumé du jour',
      StatsPeriod.week => 'Résumé de la semaine',
      StatsPeriod.month => 'Résumé du mois',
    };

String _periodRange(StatsPeriod period) {
  final now = DateTime.now();
  final start = statsPeriodStart(period, now);
  final dateFormat = DateFormat('EEEE d MMMM', 'fr_MA');
  return switch (period) {
    StatsPeriod.day => 'Aujourd’hui · ${dateFormat.format(start)}',
    StatsPeriod.week =>
      'Du ${DateFormat('d MMM', 'fr_MA').format(start)} au ${DateFormat('d MMM', 'fr_MA').format(start.add(const Duration(days: 6)))}',
    StatsPeriod.month => DateFormat('MMMM yyyy', 'fr_MA').format(start),
  };
}

class _EmptyPeriodCard extends StatelessWidget {
  const _EmptyPeriodCard({required this.period});
  final StatsPeriod period;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppTheme.softWhite, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.receipt_long_outlined,
            size: 34, color: AppTheme.caramel),
        const SizedBox(height: 10),
        Text('Aucune commande ${_emptyPeriodLabel(period)}.',
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        const Text(
            'Les compteurs ci-dessus se mettront à jour automatiquement.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ]));
}

String _emptyPeriodLabel(StatsPeriod period) => switch (period) {
      StatsPeriod.day => 'aujourd’hui',
      StatsPeriod.week => 'cette semaine',
      StatsPeriod.month => 'ce mois',
    };

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.coffee)),
            Text(label)
          ])));
}
