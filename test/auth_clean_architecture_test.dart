import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/entities/user_entity.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  bool loggedOut = false;

  @override
  bool get isAuthenticated => true;

  @override
  String? get currentAccessToken => 'mock_token';

  @override
  String? get currentRefreshToken => 'mock_refresh';

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw ApiException(message: 'Invalid credentials', statusCode: 401);
    }
    return const AuthTokensEntity(
      accessToken: 'access_123',
      refreshToken: 'refresh_456',
    );
  }

  @override
  Future<UserEntity> getProfile() async {
    return const UserEntity(
      id: 1,
      email: 'john@mail.com',
      name: 'John',
      role: 'customer',
      avatar: 'https://example.com/avatar.png',
    );
  }

  @override
  Future<AuthTokensEntity> refreshToken({String? token}) async {
    return const AuthTokensEntity(
      accessToken: 'new_access',
      refreshToken: 'new_refresh',
    );
  }

  @override
  void logout() {
    loggedOut = true;
  }
}

void main() {
  group('Auth Clean Architecture Tests', () {
    late MockAuthRepository mockRepository;
    late LoginUseCase loginUseCase;
    late GetProfileUseCase getProfileUseCase;
    late LogoutUseCase logoutUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      loginUseCase = LoginUseCase(mockRepository);
      getProfileUseCase = GetProfileUseCase(mockRepository);
      logoutUseCase = LogoutUseCase(mockRepository);
    });

    test('LoginUseCase returns AuthTokensEntity on success', () async {
      final result = await loginUseCase(
        email: 'john@mail.com',
        password: 'password123',
      );
      expect(result.accessToken, 'access_123');
      expect(result.refreshToken, 'refresh_456');
    });

    test('GetProfileUseCase returns UserEntity on success', () async {
      final profile = await getProfileUseCase();
      expect(profile.id, 1);
      expect(profile.email, 'john@mail.com');
    });

    test('LogoutUseCase invokes repository logout', () {
      logoutUseCase();
      expect(mockRepository.loggedOut, isTrue);
    });

    test('AuthCubit emits AuthLoading then AuthSuccess on successful login',
        () async {
      final cubit = AuthCubit(
        loginUseCase: loginUseCase,
        getProfileUseCase: getProfileUseCase,
        logoutUseCase: logoutUseCase,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ]),
      );

      await cubit.login(email: 'john@mail.com', password: 'password123');
      await expectation;

      final state = cubit.state as AuthSuccess;
      expect(state.tokens.accessToken, 'access_123');
    });

    test('AuthCubit emits AuthLoading then AuthFailure on error', () async {
      mockRepository.shouldFail = true;
      final cubit = AuthCubit(
        loginUseCase: loginUseCase,
        getProfileUseCase: getProfileUseCase,
        logoutUseCase: logoutUseCase,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ]),
      );

      await cubit.login(email: 'john@mail.com', password: 'wrong');
      await expectation;

      final state = cubit.state as AuthFailure;
      expect(state.message, 'Invalid credentials');
    });
  });
}
