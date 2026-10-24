import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

/// Use case for retrieving product details by ID
class GetProductByIdUseCase {
  final HomeRepository repository;

  const GetProductByIdUseCase(this.repository);

  Future<ProductEntity> call(int id) {
    return repository.getProductById(id);
  }
}
