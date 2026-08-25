import 'package:cofino/features/manager/providers/manager_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 23, 15, 30);
  test(
      'période jour',
      () => expect(
          statsPeriodStart(StatsPeriod.day, now), DateTime(2026, 8, 23)));
  test(
      'période semaine commence lundi',
      () => expect(
          statsPeriodStart(StatsPeriod.week, now), DateTime(2026, 8, 17)));
  test(
      'période mois',
      () =>
          expect(statsPeriodStart(StatsPeriod.month, now), DateTime(2026, 8)));
}
