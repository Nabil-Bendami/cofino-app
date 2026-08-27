import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/team_repository.dart';

final managerOrdersProvider = FutureProvider<List<Map<String, dynamic>>>(
    (ref) => ref.watch(orderRepositoryProvider).getManagerOrders());
final newOrdersProvider = StreamProvider<List<Map<String, dynamic>>>(
    (ref) => ref.watch(orderRepositoryProvider).watchNewOrders());
final teamProvider = FutureProvider<List<Profile>>(
    (ref) => ref.watch(teamRepositoryProvider).getServers());

enum StatsPeriod { day, week, month }

DateTime statsPeriodStart(StatsPeriod period, DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  return switch (period) {
    StatsPeriod.day => day,
    StatsPeriod.week => day.subtract(Duration(days: day.weekday - 1)),
    StatsPeriod.month => DateTime(now.year, now.month),
  };
}

final statisticsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, StatsPeriod>((ref, period) {
  final now = DateTime.now();
  return ref.watch(orderRepositoryProvider).statistics(
      statsPeriodStart(period, now), now.add(const Duration(seconds: 1)));
});
