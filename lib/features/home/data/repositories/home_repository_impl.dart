import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

/// Concrete implementation of [HomeRepository] utilizing [HomeRemoteDataSource]
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({HomeRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? HomeRemoteDataSourceImpl();

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    return await remoteDataSource.getAllProducts(
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    return await remoteDataSource.getProductsByCategory(
      categoryId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    return await remoteDataSource.getProductById(id);
  }
}
