import 'package:cofino/core/routing/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un utilisateur non connecté est dirigé vers l’accueil', () {
    expect(
        resolveAppRedirect(
            location: '/manager', authenticated: false, profileLoading: false),
        '/welcome');
  });
  test('les écrans publics restent accessibles sans session', () {
    for (final route in ['/welcome', '/login', '/signup']) {
      expect(
        resolveAppRedirect(
          location: route,
          authenticated: false,
          profileLoading: false,
        ),
        isNull,
      );
    }
  });
  test('un manager ne peut pas ouvrir les routes serveur', () {
    expect(
        resolveAppRedirect(
            location: '/server/cart',
            authenticated: true,
            profileLoading: false,
            profile: const RouteProfile(role: 'manager', isActive: true)),
        '/manager');
  });
  test('un serveur ne peut pas ouvrir les routes manager', () {
    expect(
        resolveAppRedirect(
            location: '/manager/stats',
            authenticated: true,
            profileLoading: false,
            profile: const RouteProfile(role: 'serveur', isActive: true)),
        '/server');
  });
  test('un compte inactif ne passe pas la garde', () {
    expect(
        resolveAppRedirect(
            location: '/server',
            authenticated: true,
            profileLoading: false,
            profile: const RouteProfile(role: 'serveur', isActive: false)),
        '/login');
  });
}
