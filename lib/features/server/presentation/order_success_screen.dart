import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});
  final Map<String, dynamic> order;
  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        size: 96, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 20),
                    Text('Commande confirmée',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('Commande #${order['order_number']}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(DateFormat('dd MMMM yyyy · HH:mm', 'fr_MA')
                        .format(DateTime.parse(order['created_at']).toLocal())),
                    const SizedBox(height: 8),
                    Text(
                        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD')
                            .format(order['total']),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('La commande a été envoyée au Manager.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 30),
                    FilledButton(
                        onPressed: () => context.go('/server'),
                        child: const Text('Retour au menu'))
                  ]))));
}
