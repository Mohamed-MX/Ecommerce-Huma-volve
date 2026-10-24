import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Concrete implementation of [AuthRepository] combining Remote and Local data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
  })  : remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(),
        localDataSource = localDataSource ?? AuthLocalDataSourceImpl();

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    final authResponse = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save tokens locally for subsequent requests
    localDataSource.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  @override
  Future<UserEntity> getProfile() async {
    if (!isAuthenticated) {
      throw ApiException(
        message: 'No access token available. Please login first.',
        statusCode: 401,
      );
    }
    return await remoteDataSource.getProfile();
  }

  @override
  Future<AuthTokensEntity> refreshToken({String? token}) async {
    final targetToken = token ?? localDataSource.getRefreshToken();
    if (targetToken == null || targetToken.isEmpty) {
      throw ApiException(
        message: 'No refresh token available to refresh session.',
        statusCode: 400,
      );
    }

    final authResponse = await remoteDataSource.refreshToken(
      refreshToken: targetToken,
    );

    localDataSource.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  @override
  void logout() {
    localDataSource.clearTokens();
  }

  @override
  bool get isAuthenticated => localDataSource.isAuthenticated;

  @override
  String? get currentAccessToken => localDataSource.getAccessToken();

  @override
  String? get currentRefreshToken => localDataSource.getRefreshToken();
}
