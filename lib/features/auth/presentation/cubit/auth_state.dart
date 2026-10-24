import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for all Authentication presentation states
abstract class AuthState {
  const AuthState();
}

/// Initial state when auth screen loads
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State while an authentication request is in flight
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when login or token operation succeeds
class AuthSuccess extends AuthState {
  final AuthTokensEntity tokens;
  final UserEntity? user;

  const AuthSuccess({
    required this.tokens,
    this.user,
  });
}

/// State when an authentication operation fails
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});
}

/// State when user logs out
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
