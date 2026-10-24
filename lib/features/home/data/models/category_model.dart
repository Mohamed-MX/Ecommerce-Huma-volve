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
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
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
