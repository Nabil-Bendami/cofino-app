import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/menu_repository.dart';

List<Product> filterActiveProducts(Iterable<Product> products) =>
    products.where((product) => product.isActive).toList(growable: false);

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getCategories();
});

final activeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getActiveProducts();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getAllProducts();
});
