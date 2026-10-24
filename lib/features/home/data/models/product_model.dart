import '../../domain/entities/product_entity.dart';
import 'category_model.dart';

/// Data model representing a Product in Platzi Fake Store API.
/// Maps to [ProductEntity] in the domain layer.
class ProductModel extends ProductEntity {
  ProductModel({
    required super.rawId,
    required super.title,
    required super.description,
    required super.price,
    required super.images,
    super.category,
    super.colors,
    super.sizes,
  });

  /// Clean and sanitize image URLs returned by Platzi API.
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
      if (category != null && category is CategoryModel)
        'category': (category as CategoryModel).toJson(),
    };
  }
}
