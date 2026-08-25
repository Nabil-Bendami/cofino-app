import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String cafeId;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imagePath;
  final bool isActive;

  const Product({
    required this.id,
    required this.cafeId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      cafeId: json['cafe_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imagePath: json['image_path'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafe_id': cafeId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        cafeId,
        categoryId,
        name,
        description,
        price,
        imagePath,
        isActive,
      ];
}
