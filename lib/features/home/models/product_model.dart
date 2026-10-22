import 'package:flutter/material.dart';

import '../../../core/dummy_data.dart';
import 'category_model.dart';

/// Model representing a Product in Platzi Fake Store API.
/// Extends [Product] to maintain seamless compatibility with existing
/// [ProductCard] and [ProductDetailsScreen] widgets.
class ProductModel extends Product {
  final int rawId;
  final String title;
  final List<String> images;
  final CategoryModel? category;

  ProductModel({
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

  /// Clean and sanitize image URLs returned by Platzi API.
  /// (Handles escaped strings like '["https://..."]' or non-http strings).
  static List<String> sanitizeImages(dynamic rawImages) {
    if (rawImages == null) return [];
    final List<String> cleaned = [];
    if (rawImages is List) {
      for (final item in rawImages) {
        var str = item.toString().trim();
        if (str.startsWith('["') && str.endsWith('"]')) {
          str = str.substring(2, str.length - 2);
        } else if (str.startsWith('[') && str.endsWith(']')) {
          str = str.substring(1, str.length - 1).replaceAll('"', '');
        }
        str = str.replaceAll(r'\"', '');
        if (str.isNotEmpty &&
            (str.startsWith('http://') || str.startsWith('https://'))) {
          cleaned.add(str);
        }
      }
    }
    return cleaned;
  }

  /// Factory constructor to parse a [ProductModel] from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final cleanedImages = sanitizeImages(json['images']);

    final idVal = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;

    final priceNum = json['price'];
    final double priceVal = (priceNum is num) ? priceNum.toDouble() : 0.0;

    CategoryModel? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    }

    return ProductModel(
      rawId: idVal,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: priceVal,
      images: cleanedImages,
      category: cat,
    );
  }

  /// Convert [ProductModel] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': rawId,
      'title': title,
      'price': price,
      'description': description,
      'images': images,
      if (category != null) 'category': category!.toJson(),
    };
  }

  @override
  String toString() => 'ProductModel(id: $rawId, title: $title, price: $price)';
}
