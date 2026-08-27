import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/role_navigation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/supabase/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../menu/providers/menu_provider.dart';
import '../providers/cart_provider.dart';

class ServerMenuScreen extends ConsumerStatefulWidget {
  const ServerMenuScreen({super.key});

  @override
  ConsumerState<ServerMenuScreen> createState() => _ServerMenuScreenState();
}

class _ServerMenuScreenState extends ConsumerState<ServerMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(activeProductsProvider);
    final cartState = ref.watch(cartProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;

    final currencyFormat =
        NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const ServerNavigation(index: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Charcoal header inspired by the coffee ordering reference.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                color: AppTheme.darkRoast,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.goldenAmber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.goldenAmber, width: 1.5),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child:
                                Icon(Icons.person, color: AppTheme.goldenAmber),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: AppTheme.goldenAmber),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile?.cafeName ?? 'Café Central',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Bonjour, ${profile?.fullName ?? 'Serveur'}',
                              style: const TextStyle(
                                color: Color(0xFFD1D1D3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: Colors.white, size: 22),
                          onPressed: () => context.push('/server/history'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        });
                      },
                      style: const TextStyle(
                          color: AppTheme.darkRoast, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une boisson…',
                        hintStyle: const TextStyle(
                            color: AppTheme.mutedText, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppTheme.darkRoast, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // Main Scrollable Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 10),

                  // Promo Card Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF83543B),
                            Color(0xFF5C3927),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF83543B).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20,
                            top: 18,
                            bottom: 18,
                            right: 140,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Offre Spéciale 08:00 - 18:00',
                                    style: TextStyle(
                                      color: Color(0xFFF3E7DF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Buy one, Get one\nfor Free',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.goldenAmber,
                                      foregroundColor: AppTheme.darkRoast,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Commander',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            bottom: -10,
                            width: 145,
                            child: Image.asset(
                              'lib/menu-image/promo_coffee_banner.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'lib/menu-image/cappocino.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.coffee,
                                  size: 70,
                                  color: AppTheme.goldenAmber,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Categories Horizontal Bar
                  categoriesAsync.when(
                    data: (categories) => SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final category = isAll ? null : categories[index - 1];
                          final isSelected =
                              _selectedCategoryId == category?.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              child: ChoiceChip(
                                showCheckmark: false,
                                avatar: isSelected
                                    ? const Icon(Icons.local_cafe_rounded,
                                        size: 18, color: Colors.white)
                                    : const Icon(Icons.local_cafe_outlined,
                                        size: 18, color: Color(0xFF8C7B70)),
                                label: Text(isAll ? 'Tous' : category!.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategoryId =
                                        selected ? category?.id : null;
                                  });
                                },
                                backgroundColor: const Color(0xFFF5ECE4),
                                selectedColor: AppTheme.goldenAmber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide.none,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF5C493E),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 44,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const SizedBox(height: 44),
                  ),

                  const SizedBox(height: 16),

                  // Products Grid Section
                  productsAsync.when(
                    data: (products) {
                      final filteredProducts = products.where((p) {
                        final matchesSearch =
                            p.name.toLowerCase().contains(_searchQuery);
                        final matchesCategory = _selectedCategoryId == null ||
                            p.categoryId == _selectedCategoryId;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.coffee_outlined,
                                    size: 48, color: Color(0xFFC5B5A9)),
                                SizedBox(height: 12),
                                Text(
                                  'Aucun produit trouvé',
                                  style: TextStyle(
                                      color: Color(0xFF8C7B70),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.73,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final imageUrl = SupabaseService.productImageUrl(
                              product.imagePath);

                          return ProductGridCard(
                            product: product,
                            imageUrl: imageUrl,
                            currencyFormat: currencyFormat,
                            onTap: () => context.push(
                              '/server/product/${product.id}',
                              extra: product,
                            ),
                            onAdd: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} ajouté au panier'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Center(
                      child: Text('Erreur: $err',
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartState.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/server/cart'),
              backgroundColor: AppTheme.goldenAmber,
              elevation: 6,
              icon: const Icon(Icons.shopping_bag_rounded,
                  color: AppTheme.darkRoast),
              label: Text(
                '${cartState.totalItems} • ${currencyFormat.format(cartState.total)}',
                style: const TextStyle(
                  color: AppTheme.darkRoast,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            )
          : null,
    );
  }
}

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.imageUrl,
    required this.currencyFormat,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final String? imageUrl;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular product image container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F5EF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_cafe_rounded,
                              size: 46,
                              color: AppTheme.goldenAmber,
                            ),
                          )
                        : Image.asset(
                            'lib/menu-image/coffe-normal.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_cafe_rounded,
                              size: 46,
                              color: AppTheme.goldenAmber,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.darkRoast,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.description?.isNotEmpty == true
                  ? product.description!
                  : 'Express Coffee',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9E8E84),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    color: AppTheme.darkRoast,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.goldenAmber,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldenAmber.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
