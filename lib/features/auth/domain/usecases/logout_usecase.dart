import '../repositories/auth_repository.dart';

/// Use case for logging out user
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  void call() {
    repository.logout();
  }
}
