import 'package:cofino/features/auth/presentation/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('refuse un e-mail vide ou invalide', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('nabil@cofino'), isNotNull);
      expect(AuthValidators.email('nabil@cofino.ma'), isNull);
    });

    test('refuse un mot de passe trop court', () {
      expect(AuthValidators.password('123'), isNotNull);
      expect(AuthValidators.password('123456'), isNull);
    });

    test('vérifie la confirmation du mot de passe', () {
      expect(AuthValidators.confirmation('abcdef', '123456'), isNotNull);
      expect(AuthValidators.confirmation('123456', '123456'), isNull);
    });
  });
}
