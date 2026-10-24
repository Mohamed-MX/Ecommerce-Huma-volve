import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for refreshing expired access token
class RefreshTokenUseCase {
  final AuthRepository repository;

  const RefreshTokenUseCase(this.repository);

  Future<AuthTokensEntity> call({String? token}) {
    return repository.refreshToken(token: token);
  }
}
