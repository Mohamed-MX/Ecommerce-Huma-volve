/// API endpoint definitions for Platzi Fake Store API
/// Documentation: https://api.escuelajs.co/docs#/
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String refreshToken = '/auth/refresh-token';

  // Users endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static const String isEmailAvailable = '/users/is-available';

  // Products endpoints
  static const String products = '/products';
  static String productById(int id) => '/products/$id';

  // Categories endpoints
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';
  static String productsByCategory(int categoryId) =>
      '/categories/$categoryId/products';

  // Files endpoints
  static const String uploadFile = '/files/upload';
}
