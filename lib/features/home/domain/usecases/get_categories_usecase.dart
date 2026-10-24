import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

/// Use case for retrieving product categories
class GetCategoriesUseCase {
  final HomeRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}
