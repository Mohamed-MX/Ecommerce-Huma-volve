import '../../../../core/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Contract for Home remote data source
abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProductModel>> getAllProducts({
    int? limit,
    int? offset,
  });

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  });

  Future<ProductModel> getProductById(int id);
}

/// Implementation of [HomeRemoteDataSource] using [ApiClient]
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _apiClient;

  HomeRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);

    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        message: 'Unexpected categories response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (limit != null) queryParameters['limit'] = limit;
    if (offset != null) queryParameters['offset'] = offset;

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        message: 'Unexpected products response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (limit != null) queryParameters['limit'] = limit;
    if (offset != null) queryParameters['offset'] = offset;

    final response = await _apiClient.get(
      ApiEndpoints.productsByCategory(categoryId),
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.data is List) {
      final list = response.data as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        message: 'Unexpected products by category response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.productById(id));

    if (response.data is Map<String, dynamic>) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: 'Unexpected product details response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }
}
