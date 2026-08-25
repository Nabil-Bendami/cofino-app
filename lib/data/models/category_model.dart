import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String cafeId;
  final String name;
  final int sortOrder;

  const Category({
    required this.id,
    required this.cafeId,
    required this.name,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      cafeId: json['cafe_id'],
      name: json['name'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafe_id': cafeId,
      'name': name,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, cafeId, name, sortOrder];
}
