import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constants for Platzi Fake Store API configuration and HTTP headers
class ApiConstants {
  ApiConstants._();

  /// API Identity
  static const String defaultApiName = 'platzi-fake-store-api';
  static const String defaultBaseUrl = 'https://api.escuelajs.co/api/v1';
  static const String documentationUrl = 'https://api.escuelajs.co/docs#/';

  /// Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  /// Header Keys & Values
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String applicationJson = 'application/json';

  /// Resolves the base URL from .env if available, falling back to [defaultBaseUrl].
  static String get baseUrl {
    try {
      final envUrl = dotenv.env['BASE_URL'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        return envUrl.trim();
      }
    } catch (_) {
      // .env was not initialized or variable missing
    }
    return defaultBaseUrl;
  }

  /// Resolves the API name from .env if available, falling back to [defaultApiName].
  static String get apiName {
    try {
      final envName = dotenv.env['API_NAME'];
      if (envName != null && envName.trim().isNotEmpty) {
        return envName.trim();
      }
    } catch (_) {
      // .env was not initialized or variable missing
    }
    return defaultApiName;
  }
}
