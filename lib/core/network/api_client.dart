import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_constants.dart';

/// Custom Exception for network and API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

/// Central Network Client built with Dio for handling HTTP requests,
/// access tokens, interceptors, and error handling.
class ApiClient {
  static ApiClient? _instance;
  final Dio dio;

  String? _accessToken;
  String? _refreshToken;

  ApiClient._internal({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                sendTimeout: ApiConstants.sendTimeout,
                headers: {
                  ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
                  ApiConstants.acceptHeader: ApiConstants.applicationJson,
                },
              ),
            ) {
    _initializeInterceptors();
  }

  /// Singleton instance
  static ApiClient get instance => _instance ??= ApiClient._internal();

  /// Factory constructor allowing injection for testing or custom setup
  factory ApiClient({Dio? dio}) {
    if (dio != null) {
      return ApiClient._internal(customDio: dio);
    }
    return instance;
  }

  /// Current stored access token
  String? get accessToken => _accessToken;

  /// Current stored refresh token
  String? get refreshToken => _refreshToken;

  /// Check if user has an active access token
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Store access and refresh tokens
  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
  }

  /// Update only the access token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear stored authentication tokens on logout
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  void _initializeInterceptors() {
    // Authentication & Common Headers Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach Authorization Bearer header if access token exists
          if (_accessToken != null &&
              _accessToken!.isNotEmpty &&
              !options.headers.containsKey(ApiConstants.authorizationHeader)) {
            options.headers[ApiConstants.authorizationHeader] =
                '${ApiConstants.bearerPrefix}$_accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );

    // Pretty Logger in Debug Mode
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  /// Handles Dio exceptions and converts them to user-friendly [ApiException]
  ApiException _handleDioError(DioException error) {
    String message = 'An unexpected error occurred. Please try again.';
    int? statusCode = error.response?.statusCode;
    dynamic data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            message = data['message'].toString();
          } else if (data['error'] != null) {
            message = data['error'].toString();
          }
        } else if (statusCode == 401) {
          message = 'Unauthorized. Invalid credentials or expired access token.';
        } else if (statusCode == 404) {
          message = 'Requested resource not found.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error ($statusCode). Please try again later.';
        }
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Please verify your internet connection.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Security certificate error.';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? message;
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      responseData: data,
    );
  }

  /// GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
