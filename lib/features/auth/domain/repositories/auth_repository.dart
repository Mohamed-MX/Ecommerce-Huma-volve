import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

/// Contract for Authentication repository in the Domain layer
abstract class AuthRepository {
  /// Authenticate user using email and password
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  });

  /// Retrieve the authenticated user's profile
  Future<UserEntity> getProfile();

  /// Refresh the access token using a refresh token
  Future<AuthTokensEntity> refreshToken({String? token});

  /// Log out the user and clear stored credentials
  void logout();

  /// Whether the user currently has an active access token
  bool get isAuthenticated;

  /// The active access token, if any
  String? get currentAccessToken;

  /// The active refresh token, if any
  String? get currentRefreshToken;
}
