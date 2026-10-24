import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

/// Use case for retrieving products filtered by category
class GetProductsByCategoryUseCase {
  final HomeRepository repository;

  const GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call(
    int categoryId, {
    int? limit,
    int? offset,
  }) {
    return repository.getProductsByCategory(
      categoryId,
      limit: limit,
      offset: offset,
    );
  }
}
