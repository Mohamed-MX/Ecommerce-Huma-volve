/// Domain entity representing a product category
class CategoryEntity {
  final int id;
  final String name;
  final String image;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.image,
  });

  /// Default "All" category filter chip
  static const CategoryEntity all = CategoryEntity(
    id: 0,
    name: 'All',
    image: '',
  );

  /// Check if this is the "All" default filter
  bool get isAll => id == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name)';
}
