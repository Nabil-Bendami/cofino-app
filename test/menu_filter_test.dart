import 'package:cofino/data/models/product_model.dart';
import 'package:cofino/features/menu/providers/menu_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le filtre ne conserve que les produits actifs', () {
    const active = Product(
        id: '1',
        cafeId: 'c',
        categoryId: 'x',
        name: 'Café',
        price: 10,
        isActive: true);
    const inactive = Product(
        id: '2',
        cafeId: 'c',
        categoryId: 'x',
        name: 'Thé',
        price: 12,
        isActive: false);
    expect(filterActiveProducts([active, inactive]), [active]);
  });
}
