import '../../../../core/network/api_client.dart';

/// Contract for Authentication local data source (caching / session tokens)
abstract class AuthLocalDataSource {
  String? getAccessToken();
  String? getRefreshToken();
  bool get isAuthenticated;
  void saveTokens({required String accessToken, String? refreshToken});
  void clearTokens();
}

/// Implementation of [AuthLocalDataSource] backed by [ApiClient] token manager
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final ApiClient _apiClient;

  AuthLocalDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  String? getAccessToken() => _apiClient.accessToken;

  @override
  String? getRefreshToken() => _apiClient.refreshToken;

  @override
  bool get isAuthenticated => _apiClient.isAuthenticated;

  @override
  void saveTokens({required String accessToken, String? refreshToken}) {
    _apiClient.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  void clearTokens() {
    _apiClient.clearTokens();
  }
}
