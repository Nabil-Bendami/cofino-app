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
        appBar: AppBar(title: const Text('Statistiques')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<StatsPeriod>(segments: const [
                ButtonSegment(value: StatsPeriod.day, label: Text('Jour')),
                ButtonSegment(value: StatsPeriod.week, label: Text('Semaine')),
                ButtonSegment(value: StatsPeriod.month, label: Text('Mois'))
              ], selected: {
                period
              }, onSelectionChanged: (v) => setState(() => period = v.first))),
          Expanded(
              child: stats.when(
                  data: (data) {
                    final top = List<Map<String, dynamic>>.from(
                        data['top_products'] ?? []);
                    if ((data['order_count'] as num? ?? 0) == 0) {
                      return const Center(
                          child:
                              Text('Aucune statistique pour cette période.'));
                    }
                    final max = top.fold<double>(
                        1,
                        (m, e) => (e['quantity'] as num).toDouble() > m
                            ? (e['quantity'] as num).toDouble()
                            : m);
                    return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          Row(children: [
                            Expanded(
                                child: _StatCard(
                                    label: 'Commandes',
                                    value: '${data['order_count']}')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    label: 'Revenus',
                                    value: NumberFormat.currency(
                                            locale: 'fr_MA', symbol: 'MAD')
                                        .format(data['revenue'])))
                          ]),
                          const SizedBox(height: 24),
                          Text('Produits les plus commandés',
                              style: Theme.of(context).textTheme.titleLarge),
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
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false))),
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
