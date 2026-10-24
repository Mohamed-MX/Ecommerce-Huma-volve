import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

/// Contract for Home feature data operations in the Domain layer
abstract class HomeRepository {
  /// Fetch all product categories
  Future<List<CategoryEntity>> getCategories();

  /// Fetch all products with optional pagination
  Future<List<ProductEntity>> getAllProducts({
    int? limit,
    int? offset,
  });

  /// Fetch products filtered by category ID
  Future<List<ProductEntity>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  });

  /// Fetch a single product by its ID
  Future<ProductEntity> getProductById(int id);
}
