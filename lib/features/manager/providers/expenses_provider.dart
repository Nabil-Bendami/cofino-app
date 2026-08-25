import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/expense_model.dart';
import 'manager_provider.dart';

const _uuid = Uuid();

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier()
      : super([
          Expense(
            id: 'exp-1',
            title: 'Sachet Café Robusta (10 kg)',
            amount: 320.0,
            category: 'Ingrédients',
            date: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          Expense(
            id: 'exp-2',
            title: 'Cartons de Lait & Sucre',
            amount: 150.0,
            category: 'Ingrédients',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Expense(
            id: 'exp-3',
            title: 'Facture Électricité & Eau',
            amount: 450.0,
            category: 'Factures / Loyer',
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ]);

  void addExpense({
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) {
    final newExpense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    );
    state = [newExpense, ...state];
  }

  void deleteExpense(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  double getTotalForPeriod(StatsPeriod period) {
    final now = DateTime.now();
    final start = statsPeriodStart(period, now);
    return state
        .where((e) => e.date.isAfter(start) || e.date.isAtSameMomentAs(start))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  List<Expense> getExpensesForPeriod(StatsPeriod period) {
    final now = DateTime.now();
    final start = statsPeriodStart(period, now);
    return state
        .where((e) => e.date.isAfter(start) || e.date.isAtSameMomentAs(start))
        .toList();
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
