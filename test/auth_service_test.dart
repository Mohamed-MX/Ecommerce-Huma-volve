import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/core/api_constants.dart';
import 'package:ecommerce_app_huma_volve/core/api_endpoints.dart';
import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/features/services/login_service.dart';

void main() {
  group('ApiConstants & ApiEndpoints Tests', () {
    test('ApiConstants provides valid defaults', () {
      expect(ApiConstants.defaultApiName, 'platzi-fake-store-api');
      expect(ApiConstants.defaultBaseUrl, 'https://api.escuelajs.co/api/v1');
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.apiName, 'platzi-fake-store-api');
    });

    test('ApiEndpoints defines correct authentication routes', () {
      expect(ApiEndpoints.login, '/auth/login');
      expect(ApiEndpoints.profile, '/auth/profile');
      expect(ApiEndpoints.refreshToken, '/auth/refresh-token');
      expect(ApiEndpoints.users, '/users');
      expect(ApiEndpoints.products, '/products');
    });
  });

  group('ApiClient Tests', () {
    test('Token management updates correctly', () {
      final client = ApiClient();
      expect(client.isAuthenticated, isFalse);

      client.setTokens(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
      );

      expect(client.isAuthenticated, isTrue);
      expect(client.accessToken, 'mock_access_token');
      expect(client.refreshToken, 'mock_refresh_token');

      client.clearTokens();
      expect(client.isAuthenticated, isFalse);
      expect(client.accessToken, isNull);
      expect(client.refreshToken, isNull);
    });

    test('Auth interceptor adds Bearer token to request headers', () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://example.com',
          validateStatus: (status) => true,
        ),
      );

      final client = ApiClient(dio: dio);
      client.setTokens(accessToken: 'test_secret_jwt');

      // Interceptor should attach authorization header
      RequestOptions options = RequestOptions(path: '/test');
      for (var interceptor in dio.interceptors) {
        if (interceptor is InterceptorsWrapper) {
          final handler = RequestInterceptorHandler();
          interceptor.onRequest(options, handler);
        }
      }

      expect(
        options.headers[ApiConstants.authorizationHeader],
        'Bearer test_secret_jwt',
      );
    });
  });

  group('LoginService Tests', () {
    test('LoginService manages tokens on logout', () {
      final client = ApiClient();
      client.setTokens(accessToken: 'token123');
      final service = LoginService(apiClient: client);

      expect(service.isAuthenticated, isTrue);
      expect(service.currentAccessToken, 'token123');

      service.logout();
      expect(service.isAuthenticated, isFalse);
      expect(service.currentAccessToken, isNull);
    });
  });
}
