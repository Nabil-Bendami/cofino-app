import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../supabase/supabase_service.dart';

final menuRepositoryProvider = Provider((ref) => MenuRepository());

class MenuRepository {
  Future<List<Category>> getCategories() async => (await SupabaseService.client
          .from('categories')
          .select()
          .order('sort_order'))
      .map<Category>((e) => Category.fromJson(e))
      .toList();
  Future<List<Product>> getActiveProducts() async =>
      (await SupabaseService.client
              .from('products')
              .select()
              .eq('is_active', true)
              .order('name'))
          .map<Product>((e) => Product.fromJson(e))
          .toList();
  Future<List<Product>> getAllProducts() async =>
      (await SupabaseService.client.from('products').select().order('name'))
          .map<Product>((e) => Product.fromJson(e))
          .toList();
  Future<void> saveCategory(
      {String? id,
      required String cafeId,
      required String name,
      int sortOrder = 0}) async {
    final values = {
      'cafe_id': cafeId,
      'name': name.trim(),
      'sort_order': sortOrder
    };
    if (id == null) {
      await SupabaseService.client.from('categories').insert(values);
    } else {
      await SupabaseService.client
          .from('categories')
          .update(values)
          .eq('id', id);
    }
  }

  Future<void> deleteCategory(String id) =>
      SupabaseService.client.from('categories').delete().eq('id', id);
  Future<void> saveProduct(
      {String? id,
      required String cafeId,
      required String categoryId,
      required String name,
      required double price,
      String? description,
      String? imagePath,
      bool isActive = true}) async {
    final values = {
      'cafe_id': cafeId,
      'category_id': categoryId,
      'name': name.trim(),
      'price': price,
      'description': description?.trim(),
      'image_path': imagePath,
      'is_active': isActive
    };
    if (id == null) {
      await SupabaseService.client.from('products').insert(values);
    } else {
      await SupabaseService.client.from('products').update(values).eq('id', id);
    }
  }

  Future<void> setProductActive(String id, bool active) =>
      SupabaseService.client
          .from('products')
          .update({'is_active': active}).eq('id', id);
  Future<void> deleteProduct(String id) =>
      SupabaseService.client.from('products').delete().eq('id', id);
  Future<String> uploadProductImage(String cafeId, XFile image) async {
    final extension = image.name.split('.').last.toLowerCase();
    final path =
        '$cafeId/products/${DateTime.now().microsecondsSinceEpoch}.$extension';
    final Uint8List bytes = await image.readAsBytes();
    await SupabaseService.client.storage.from('product-images').uploadBinary(
        path, bytes,
        fileOptions: FileOptions(
            contentType: extension == 'png' ? 'image/png' : 'image/jpeg'));
    return path;
  }
}
