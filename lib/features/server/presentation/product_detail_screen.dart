import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/supabase/supabase_service.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;
  String selectedSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final image = SupabaseService.productImageUrl(p.imagePath);
    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Hero Image Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),

                  // Header Controls (Back button & Favorite icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: AppTheme.darkRoast),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: isFavorite
                                ? const Color(0xFFE53935)
                                : AppTheme.darkRoast,
                          ),
                          onPressed: () {
                            setState(() => isFavorite = !isFavorite);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Hero Image Display Container
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: image != null
                                ? Image.network(
                                    image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'lib/menu-image/coffe-normal.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.coffee_rounded,
                                        size: 100,
                                        color: AppTheme.goldenAmber,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'lib/menu-image/coffe-normal.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.coffee_rounded,
                                      size: 100,
                                      color: AppTheme.goldenAmber,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Flavor Pill Tag Indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3ECE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_cafe_rounded,
                              size: 16, color: AppTheme.cocoaBanner),
                          SizedBox(width: 6),
                          Text(
                            'Chocolate/Milk',
                            style: TextStyle(
                              color: AppTheme.darkRoast,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Product Title & Quantity Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                color: AppTheme.darkRoast,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.description?.isNotEmpty == true
                                  ? p.description!
                                  : 'with chocolate and milk',
                              style: const TextStyle(
                                color: Color(0xFF8C7B70),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Counter Box Widget
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.goldenAmber.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: quantity > 1
                                      ? AppTheme.darkRoast
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkRoast,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => quantity++),
                              borderRadius: BorderRadius.circular(10),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: AppTheme.darkRoast,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Choose Sizes Header
                  const Text(
                    'Choose Sizes',
                    style: TextStyle(
                      color: AppTheme.darkRoast,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Size Cards Row
                  Row(
                    children: [
                      _SizeOptionCard(
                        label: 'Small',
                        price: currencyFormat.format(p.price * 0.8),
                        iconSize: 22,
                        isSelected: selectedSize == 'Small',
                        onTap: () => setState(() => selectedSize = 'Small'),
                      ),
                      const SizedBox(width: 12),
                      _SizeOptionCard(
                        label: 'Medium',
                        price: currencyFormat.format(p.price),
                        iconSize: 28,
                        isSelected: selectedSize == 'Medium',
                        onTap: () => setState(() => selectedSize = 'Medium'),
                      ),
                      const SizedBox(width: 12),
                      _SizeOptionCard(
                        label: 'Large',
                        price: currencyFormat.format(p.price * 1.25),
                        iconSize: 34,
                        isSelected: selectedSize == 'Large',
                        onTap: () => setState(() => selectedSize = 'Large'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Add To Cart Pill Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    for (var i = 0; i < quantity; i++) {
                      ref.read(cartProvider.notifier).addProduct(p);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '$quantity x ${p.name} ($selectedSize) ajouté au panier'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.goldenAmber,
                    foregroundColor: AppTheme.darkRoast,
                    elevation: 4,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: AppTheme.darkRoast, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Add to cart • ${currencyFormat.format(p.price * quantity)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOptionCard extends StatelessWidget {
  const _SizeOptionCard({
    required this.label,
    required this.price,
    required this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String price;
  final double iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.darkRoast : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.darkRoast : const Color(0xFFF0E5DB),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.darkRoast.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.coffee_rounded,
                size: iconSize,
                color: isSelected ? AppTheme.goldenAmber : const Color(0xFF9E8E84),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.darkRoast,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFD8C7BC)
                      : const Color(0xFF9E8E84),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
