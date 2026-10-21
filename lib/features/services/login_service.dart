import '../../core/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../auth/models/auth_response_model.dart';
import '../auth/models/user_model.dart';

/// Service responsible for authentication operations with Platzi Fake Store API
class LoginService {
  final ApiClient _apiClient;

  LoginService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  /// Whether the user currently has an access token stored
  bool get isAuthenticated => _apiClient.isAuthenticated;

  /// The active access token, if any
  String? get currentAccessToken => _apiClient.accessToken;

  /// The active refresh token, if any
  String? get currentRefreshToken => _apiClient.refreshToken;

  /// Authenticate user using email and password.
  ///
  /// On successful authentication, saves the access and refresh tokens
  /// in [ApiClient] for subsequent authorized requests.
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
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Save access token and refresh token into ApiClient
      _apiClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } else {
      throw ApiException(
        message: 'Unexpected login response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  /// Retrieve the authenticated user's profile using the stored access token.
  Future<UserModel> getProfile() async {
    if (!isAuthenticated) {
      throw ApiException(
        message: 'No access token available. Please login first.',
        statusCode: 401,
      );
    }

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

  /// Refresh the access token using a refresh token.
  Future<AuthResponseModel> refreshToken({String? token}) async {
    final targetToken = token ?? _apiClient.refreshToken;
    if (targetToken == null || targetToken.isEmpty) {
      throw ApiException(
        message: 'No refresh token available to refresh session.',
        statusCode: 400,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {
        'refreshToken': targetToken,
      },
    );

    if (response.data is Map<String, dynamic>) {
      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Update tokens
      _apiClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } else {
      throw ApiException(
        message: 'Unexpected refresh token response format',
        statusCode: response.statusCode,
        responseData: response.data,
      );
    }
  }

  /// Clear stored authentication tokens
  void logout() {
    _apiClient.clearTokens();
  }
}
