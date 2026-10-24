import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

/// Presentation Logic Holder managing Authentication state
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    LoginUseCase? loginUseCase,
    GetProfileUseCase? getProfileUseCase,
    LogoutUseCase? logoutUseCase,
  })  : _loginUseCase = loginUseCase ?? LoginUseCase(AuthRepositoryImpl()),
        _getProfileUseCase =
            getProfileUseCase ?? GetProfileUseCase(AuthRepositoryImpl()),
        _logoutUseCase = logoutUseCase ?? LogoutUseCase(AuthRepositoryImpl()),
        super(const AuthInitial());

  /// Perform login with email and password via [LoginUseCase]
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final tokens = await _loginUseCase(
        email: email,
        password: password,
      );

      emit(AuthSuccess(tokens: tokens));
    } on ApiException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Fetch authenticated user profile via [GetProfileUseCase]
  Future<void> loadProfile() async {
    try {
      final user = await _getProfileUseCase();
      final currentState = state;
      if (currentState is AuthSuccess) {
        emit(AuthSuccess(tokens: currentState.tokens, user: user));
      }
    } catch (e) {
      emit(AuthFailure(message: 'Failed to fetch user profile: $e'));
    }
  }

  /// Perform logout via [LogoutUseCase]
  void logout() {
    _logoutUseCase();
    emit(const AuthLoggedOut());
  }
}
