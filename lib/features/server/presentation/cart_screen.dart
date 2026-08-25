import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../../../data/repositories/order_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/order_submission_guard.dart';
import '../../../core/widgets/role_navigation.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isConfirming = false;
  final TextEditingController _noteController = TextEditingController();
  final String _requestId = const Uuid().v4();
  final OrderSubmissionGuard<Map<String, dynamic>> _submission =
      OrderSubmissionGuard();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder(WidgetRef ref, BuildContext context) async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      final itemsParam = cartState.items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final response = await _submission.submit(
          _requestId,
          () => ref.read(orderRepositoryProvider).createOrder(
              items: itemsParam,
              requestId: _requestId,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim()));

      ref.read(cartProvider.notifier).clear();

      if (!context.mounted) return;

      context.go('/server/order-success', extra: response);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');

    return Scaffold(
      bottomNavigationBar: const ServerNavigation(index: 1),
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: cartState.items.isEmpty
          ? const Center(child: Text('Votre panier est vide.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(currencyFormat.format(item.product.price),
                                    style: const TextStyle(
                                        color: AppTheme.caramel)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          item.product, item.quantity - 1);
                                },
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          item.product, item.quantity + 1);
                                },
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  currencyFormat.format(item.subtotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.softWhite,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkBrown.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Remarque (facultative)',
                            hintText: 'Ex: Sans sucre',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormat.format(cartState.total),
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.coffee),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isConfirming
                              ? null
                              : () => _confirmOrder(ref, context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isConfirming
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Confirmer la commande',
                                  style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
