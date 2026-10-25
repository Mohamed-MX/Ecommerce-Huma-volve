import '../../domain/entities/category_entity.dart';

/// Data model representing a product category in Platzi Fake Store API.
/// Maps to [CategoryEntity] in the domain layer.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.image,
  });

  /// Factory constructor to create a [CategoryModel] from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    var rawName = json['name']?.toString() ?? '';
    final lower = rawName.trim().toLowerCase();

    // Platzi Fake Store API public users often rename Category 1 ("Clothes")
    // to test values like "Updated Category Name", "updated categorie name", etc.
    if (lower.contains('updated categor') ||
        lower.contains('updated categorie') ||
        (rawId == 1 &&
            (lower.contains('update') ||
                lower.contains('ctg') ||
                lower == 'change title' ||
                lower.isEmpty))) {
      rawName = 'Clothes';
    }

    return CategoryModel(
      id: rawId,
      name: rawName,
      image: json['image']?.toString() ?? '',
    );
  }

  /// Convert [CategoryModel] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  /// Default "All" category filter chip
  static const CategoryModel all = CategoryModel(
    id: 0,
    name: 'All',
    image: '',
  );
}
