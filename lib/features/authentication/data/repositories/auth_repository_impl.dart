import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Store auth data locally
      await _storeAuthData(result);

      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Store auth data locally
      await _storeAuthData(result);

      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Try to logout on server first
      await remoteDataSource.logout();

      // Clear local data regardless of server response
      await _clearAuthData();

      return const Right(unit);
    } on NetworkException catch (e) {
      // Even if network fails, clear local data
      await _clearAuthData();
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      // Even if server fails, clear local data
      await _clearAuthData();
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      // Always clear local data
      await _clearAuthData();
      return Left(UnexpectedFailure('An unexpected error occurred during logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final cachedUser = await _getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If not in cache, get from server
      final result = await remoteDataSource.getCurrentUser();
      
      // Update cache
      await storageService.saveUserData(result.toJson());

      return Right(result.toEntity());
    } on NetworkException catch (e) {
      // Try to return cached user on network error
      final cachedUser = await _getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(NetworkFailure(e.message, e.code));
    } on AuthenticationException catch (e) {
      // Clear invalid auth data
      await _clearAuthData();
      return Left(AuthenticationFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await storageService.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await storageService.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  Future<void> _storeAuthData(result) async {
    await storageService.saveAuthToken(result.token);
    await storageService.saveUserData(result.userModel.toJson());
  }

  Future<void> _clearAuthData() async {
    await storageService.clearAuthToken();
    await storageService.clearUserData();
  }

  Future<User?> _getCachedUser() async {
    try {
      final userData = storageService.getUserData();
      if (userData != null) {
        return UserModel.fromJson(userData).toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}