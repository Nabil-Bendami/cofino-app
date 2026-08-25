import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/role_navigation.dart';
import '../../../data/models/expense_model.dart';
import '../providers/expenses_provider.dart';
import '../providers/manager_provider.dart';

class ManagerStatsScreen extends ConsumerStatefulWidget {
  const ManagerStatsScreen({super.key});

  @override
  ConsumerState<ManagerStatsScreen> createState() => _ManagerStatsScreenState();
}

class _ManagerStatsScreenState extends ConsumerState<ManagerStatsScreen> {
  StatsPeriod period = StatsPeriod.day;

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Ingrédients';

    final categories = [
      'Ingrédients',
      'Fournitures',
      'Factures / Loyer',
      'Salaires',
      'Autre',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ajouter une Charge / Dépense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkRoast,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Libellé de la charge',
                      hintText: 'ex. Achat sachet café, Lait, Sucre...',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Montant (MAD)',
                      hintText: 'ex. 250.00',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catégorie',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkRoast,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppTheme.goldenAmber,
                        backgroundColor: const Color(0xFFF5ECE4),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkRoast,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedCategory = cat);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.goldenAmber,
                        foregroundColor: AppTheme.darkRoast,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim()) ?? 0.0;

                        if (title.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez saisir un libellé et un montant valide.'),
                            ),
                          );
                          return;
                        }

                        ref.read(expensesProvider.notifier).addExpense(
                              title: title,
                              amount: amount,
                              category: selectedCategory,
                            );

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Charge "$title" ajoutée avec succès !'),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Enregistrer la charge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider(period));
    final expensesNotifier = ref.watch(expensesProvider.notifier);
    final expensesList = expensesNotifier.getExpensesForPeriod(period);
    final totalExpenses = expensesNotifier.getTotalForPeriod(period);

    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      bottomNavigationBar: const ManagerNavigation(index: 3),
      appBar: AppBar(
        title: const Text('Statistiques & Analyse'),
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _showAddExpenseDialog,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.goldenAmber,
                foregroundColor: AppTheme.darkRoast,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                'Charge',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Selector Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SegmentedButton<StatsPeriod>(
              segments: const [
                ButtonSegment(
                  value: StatsPeriod.day,
                  label: Text('Aujourd\'hui'),
                  icon: Icon(Icons.today_rounded, size: 16),
                ),
                ButtonSegment(
                  value: StatsPeriod.week,
                  label: Text('Semaine'),
                  icon: Icon(Icons.date_range_rounded, size: 16),
                ),
                ButtonSegment(
                  value: StatsPeriod.month,
                  label: Text('Mois'),
                  icon: Icon(Icons.calendar_month_rounded, size: 16),
                ),
              ],
              selected: {period},
              onSelectionChanged: (v) => setState(() => period = v.first),
            ),
          ),

          // Main Stats Content
          Expanded(
            child: statsAsync.when(
              data: (data) {
                final revenue = (data['revenue'] as num? ?? 0.0).toDouble();
                final orderCount = (data['order_count'] as num? ?? 0).toInt();
                final netProfit = revenue - totalExpenses;
                final top = List<Map<String, dynamic>>.from(
                    data['top_products'] ?? []);

                final maxQuantity = top.fold<double>(
                  1,
                  (m, e) => (e['quantity'] as num).toDouble() > m
                      ? (e['quantity'] as num).toDouble()
                      : m,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    // Financial KPI Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            title: 'Revenus',
                            value: currencyFormat.format(revenue),
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF2E7D32),
                            accentBg: const Color(0xFFE8F5E9),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiCard(
                            title: 'Charges',
                            value: currencyFormat.format(totalExpenses),
                            icon: Icons.trending_down_rounded,
                            iconColor: const Color(0xFFC62828),
                            accentBg: const Color(0xFFFFEBEE),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            title: 'Bénéfice Net',
                            value: currencyFormat.format(netProfit),
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: netProfit >= 0
                                ? AppTheme.goldenAmber
                                : const Color(0xFFC62828),
                            accentBg: netProfit >= 0
                                ? AppTheme.goldenAmber.withValues(alpha: 0.15)
                                : const Color(0xFFFFEBEE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiCard(
                            title: 'Commandes',
                            value: '$orderCount',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppTheme.darkRoast,
                            accentBg: const Color(0xFFF3ECE5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Inline Call-To-Action Banner for Charges
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B2418), Color(0xFF28170F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.darkRoast.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.goldenAmber.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.post_add_rounded,
                              color: AppTheme.goldenAmber,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enregistrer une Dépense',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ajoutez vos achats de café, lait & charges pour calculer le bénéfice réel.',
                                  style: TextStyle(
                                    color: Color(0xFFC4B4A7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _showAddExpenseDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldenAmber,
                              foregroundColor: AppTheme.darkRoast,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              elevation: 0,
                            ),
                            child: const Text(
                              '+ Charge',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Top Products Section
                    if (top.isNotEmpty) ...[
                      const Text(
                        'Produits les plus vendus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkRoast,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.only(
                            right: 16, top: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: BarChart(
                          BarChartData(
                            maxY: maxQuantity + 1,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 28),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < top.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          top[index]['name'],
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              for (var i = 0; i < top.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (top[i]['quantity'] as num)
                                          .toDouble(),
                                      color: AppTheme.goldenAmber,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...top.asMap().entries.map(
                            (e) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.04)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.goldenAmber.withValues(alpha: 0.2),
                                  child: Text(
                                    '#${e.key + 1}',
                                    style: const TextStyle(
                                      color: AppTheme.darkRoast,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  e.value['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5ECE4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e.value['quantity']} vendu(s)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.darkRoast,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],

                    const SizedBox(height: 24),

                    // Expenses (Charges) Breakdown Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Détail des Charges',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkRoast,
                          ),
                        ),
                        Text(
                          '${expensesList.length} enregistrée(s)',
                          style: const TextStyle(
                            color: Color(0xFF8C7B70),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (expensesList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'Aucune charge enregistrée pour cette période.',
                            style: TextStyle(color: Color(0xFF8C7B70)),
                          ),
                        ),
                      )
                    else
                      ...expensesList.map(
                        (expense) => _ExpenseItemCard(
                          expense: expense,
                          currencyFormat: currencyFormat,
                          onDelete: () {
                            ref
                                .read(expensesProvider.notifier)
                                .deleteExpense(expense.id);
                          },
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Statistiques indisponibles\n$e',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => ref.invalidate(statisticsProvider(period)),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.accentBg,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8C7B70),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItemCard extends StatelessWidget {
  const _ExpenseItemCard({
    required this.expense,
    required this.currencyFormat,
    required this.onDelete,
  });

  final Expense expense;
  final NumberFormat currencyFormat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm', 'fr_MA');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_rounded,
            color: Color(0xFFC62828),
            size: 22,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppTheme.darkRoast,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECE4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                expense.category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkRoast,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateFormat.format(expense.date),
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E8E84)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '- ${currencyFormat.format(expense.amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFC62828),
                fontSize: 13,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

