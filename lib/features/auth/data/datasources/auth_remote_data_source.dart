import '../../../../core/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Contract for Authentication remote data source
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getProfile();

  Future<AuthResponseModel> refreshToken({required String refreshToken});
}

/// Implementation of [AuthRemoteDataSource] utilizing [ApiClient]
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (response.data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: 'Unexpected login response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);

    if (response.data is Map<String, dynamic>) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: 'Unexpected profile response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {
        'refreshToken': refreshToken,
      },
    );

    if (response.data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        message: 'Unexpected refresh token response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }
}
