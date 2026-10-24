import 'package:flutter/material.dart';

import '../../../../core/dummy_data.dart';
import 'category_entity.dart';

/// Domain entity representing a product in the catalog.
/// Extends [Product] to maintain seamless integration with existing UI widgets.
class ProductEntity extends Product {
  final int rawId;
  final String title;
  final List<String> images;
  final CategoryEntity? category;

  ProductEntity({
    required this.rawId,
    required this.title,
    required super.description,
    required super.price,
    required this.images,
    this.category,
    List<Color>? colors,
    List<String>? sizes,
  }) : super(
          id: rawId.toString(),
          name: title,
          imageUrl: _resolveFirstImage(images),
          colors: colors ??
              const [
                Color(0xFF2C3E50),
                Color(0xFFE74C3C),
                Color(0xFF3498DB),
                Color(0xFF95A5A6),
              ],
          sizes: sizes ?? const ['S', 'M', 'L', 'XL'],
        );

  static const String fallbackImage =
      'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=600&q=80';

  static String _resolveFirstImage(List<String> images) {
    if (images.isNotEmpty && images.first.isNotEmpty) {
      return images.first;
    }
    return fallbackImage;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          rawId == other.rawId;

  @override
  int get hashCode => rawId.hashCode;

  @override
  String toString() => 'ProductEntity(id: $rawId, title: $title, price: $price)';
}
