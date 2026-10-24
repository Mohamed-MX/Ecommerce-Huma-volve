import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in with email and password
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<AuthTokensEntity> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
