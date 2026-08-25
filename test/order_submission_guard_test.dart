import 'package:cofino/core/utils/order_submission_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deux confirmations avec le même identifiant ne créent qu’une commande',
      () async {
    final guard = OrderSubmissionGuard<Map<String, dynamic>>();
    var calls = 0;
    Future<Map<String, dynamic>> create() async {
      calls++;
      await Future<void>.delayed(Duration.zero);
      return {'order_number': 42};
    }

    final results = await Future.wait(
        [guard.submit('request-1', create), guard.submit('request-1', create)]);
    expect(calls, 1);
    expect(results[0]['order_number'], 42);
    expect(results[1], results[0]);
  });
}
