import '../../domain/entities/auth_tokens_entity.dart';

/// Data model representing Platzi Fake Store API authentication response.
/// Maps to [AuthTokensEntity] in the domain layer.
class AuthResponseModel extends AuthTokensEntity {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
