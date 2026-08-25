import 'package:flutter_test/flutter_test.dart';
import 'package:cofino/data/models/product_model.dart';
import 'package:cofino/features/server/providers/cart_provider.dart';

void main() {
  group('CartNotifier', () {
    const product1 = Product(
      id: 'p1',
      cafeId: 'c1',
      categoryId: 'cat1',
      name: 'Espresso',
      price: 15.0,
      isActive: true,
    );

    const product2 = Product(
      id: 'p2',
      cafeId: 'c1',
      categoryId: 'cat1',
      name: 'Cappuccino',
      price: 25.0,
      isActive: true,
    );

    late CartNotifier cartNotifier;

    setUp(() {
      cartNotifier = CartNotifier();
    });

    test('Initial state is empty', () {
      expect(cartNotifier.state.items, isEmpty);
      expect(cartNotifier.state.total, 0.0);
    });

    test('Add product increments quantity or adds new item', () {
      cartNotifier.addProduct(product1);
      expect(cartNotifier.state.items.length, 1);
      expect(cartNotifier.state.items.first.quantity, 1);
      expect(cartNotifier.state.total, 15.0);

      cartNotifier.addProduct(product1);
      expect(cartNotifier.state.items.length, 1);
      expect(cartNotifier.state.items.first.quantity, 2);
      expect(cartNotifier.state.total, 30.0);
    });

    test('Update quantity changes quantity or removes item if <= 0', () {
      cartNotifier.addProduct(product1);
      cartNotifier.updateQuantity(product1, 3);
      expect(cartNotifier.state.items.first.quantity, 3);
      expect(cartNotifier.state.total, 45.0);

      cartNotifier.updateQuantity(product1, 0);
      expect(cartNotifier.state.items, isEmpty);
    });

    test('Total calculation with multiple products', () {
      cartNotifier.addProduct(product1);
      cartNotifier.addProduct(product2);
      cartNotifier.updateQuantity(product2, 2);

      expect(cartNotifier.state.items.length, 2);
      // product1 (15*1) + product2 (25*2) = 65
      expect(cartNotifier.state.total, 65.0);
    });

    test('Set note', () {
      cartNotifier.setNote('Sans sucre');
      expect(cartNotifier.state.note, 'Sans sucre');
    });

    test('Clear cart', () {
      cartNotifier.addProduct(product1);
      cartNotifier.clear();
      expect(cartNotifier.state.items, isEmpty);
    });
  });
}
