import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

/// Use case for retrieving all products
class GetAllProductsUseCase {
  final HomeRepository repository;

  const GetAllProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    int? limit,
    int? offset,
  }) {
    return repository.getAllProducts(limit: limit, offset: offset);
  }
}
