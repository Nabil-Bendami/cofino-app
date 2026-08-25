import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_model.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

class CartState extends Equatable {
  final List<CartItem> items;
  final String? note;

  const CartState({this.items = const [], this.note});

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items, String? note}) {
    return CartState(
      items: items ?? this.items,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [items, note];
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(Product product) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
          items: [...state.items, CartItem(product: product, quantity: 1)]);
    }
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeProduct(product);
      return;
    }
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] =
          updatedItems[existingIndex].copyWith(quantity: quantity);
      state = state.copyWith(items: updatedItems);
    }
  }

  void removeProduct(Product product) {
    final updatedItems =
        state.items.where((item) => item.product.id != product.id).toList();
    state = state.copyWith(items: updatedItems);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
