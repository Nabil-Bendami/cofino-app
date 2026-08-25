import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/manager/presentation/manager_dashboard.dart';
import '../../features/manager/presentation/manager_history_screen.dart';
import '../../features/manager/presentation/manager_menu_screen.dart';
import '../../features/manager/presentation/manager_stats_screen.dart';
import '../../features/manager/presentation/manager_team_screen.dart';
import '../../features/manager/presentation/manager_order_detail_screen.dart';
import '../../features/server/presentation/server_menu_screen.dart';
import '../../features/server/presentation/cart_screen.dart';
import '../../features/server/presentation/server_history_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'route_guard.dart';
import '../../data/models/product_model.dart';
import '../../features/server/presentation/product_detail_screen.dart';
import '../../features/server/presentation/order_success_screen.dart';
import '../../features/server/presentation/server_order_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = _GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  late final GoRouter router;

  router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      // Reading, rather than watching, keeps this single GoRouter instance
      // alive while the profile changes. GoRouter is refreshed below instead.
      final currentProfileAsync = ref.read(currentProfileProvider);
      final isAuth = Supabase.instance.client.auth.currentSession != null;
      final profile = currentProfileAsync.valueOrNull;
      return resolveAppRedirect(
          location: state.uri.path,
          authenticated: isAuth,
          profileLoading: currentProfileAsync.isLoading,
          profile: profile == null
              ? null
              : RouteProfile(role: profile.role, isActive: profile.isActive));
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerDashboard(),
        routes: [
          GoRoute(
            path: 'order/:id',
            builder: (context, state) =>
                ManagerOrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const ManagerHistoryScreen(),
          ),
          GoRoute(
            path: 'menu',
            builder: (context, state) => const ManagerMenuScreen(),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => const ManagerStatsScreen(),
          ),
          GoRoute(
            path: 'team',
            builder: (context, state) => const ManagerTeamScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/server',
        builder: (context, state) => const ServerMenuScreen(),
        routes: [
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const ServerHistoryScreen(),
          ),
          GoRoute(
              path: 'product/:id',
              builder: (context, state) =>
                  ProductDetailScreen(product: state.extra! as Product)),
          GoRoute(
              path: 'order/:id',
              builder: (context, state) => ServerOrderDetailScreen(
                  orderId: state.pathParameters['id']!)),
          GoRoute(
              path: 'order-success',
              builder: (context, state) => OrderSuccessScreen(
                  order: Map<String, dynamic>.from(state.extra! as Map))),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );

  // A profile change can alter the destination (manager/server/inactive), but
  // it must not recreate MaterialApp.router and its inherited dependencies.
  ref.listen(currentProfileProvider, (_, __) => router.refresh());
  ref.onDispose(() {
    authRefresh.dispose();
    router.dispose();
  });

  return router;
});

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
