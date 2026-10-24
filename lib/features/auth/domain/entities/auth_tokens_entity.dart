/// Domain entity representing authentication tokens
class AuthTokensEntity {
  final String accessToken;
  final String refreshToken;

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  bool get hasValidAccessToken => accessToken.isNotEmpty;
}
