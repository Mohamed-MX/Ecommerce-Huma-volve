import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for fetching the authenticated user profile
class GetProfileUseCase {
  final AuthRepository repository;

  const GetProfileUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.getProfile();
  }
}
