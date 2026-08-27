import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ManagerNavigation extends StatelessWidget {
  const ManagerNavigation({super.key, required this.index});
  final int index;
  static const paths = [
    '/manager',
    '/manager/history',
    '/manager/menu',
    '/manager/stats',
    '/manager/team'
  ];
  @override
  Widget build(BuildContext context) => NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => context.go(paths[value]),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Nouvelles'),
            NavigationDestination(
                icon: Icon(Icons.history), label: 'Historique'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Menu'),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Stats'),
            NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Équipe'),
          ]);
}

class ServerNavigation extends StatelessWidget {
  const ServerNavigation({super.key, required this.index});
  final int index;
  static const paths = [
    '/server',
    '/server/cart',
    '/server/history',
    '/profile'
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppTheme.goldenAmber,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppTheme.goldenAmber, size: 24);
            }
            return const IconThemeData(color: AppTheme.mutedText, size: 24);
          }),
        ),
        child: NavigationBar(
          height: 72,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: index,
          onDestinationSelected: (value) => context.go(paths[value]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Panier',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Commandes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
