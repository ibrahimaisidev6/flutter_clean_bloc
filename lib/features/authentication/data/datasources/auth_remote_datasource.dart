import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login user with email and password
  /// Throws [ServerException] on server error
  /// Throws [NetworkException] on network error
  /// Throws [AuthenticationException] on invalid credentials
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Register new user
  /// Throws [ServerException] on server error
  /// Throws [NetworkException] on network error
  /// Throws [ValidationException] on validation error
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logout current user
  /// Throws [ServerException] on server error
  /// Throws [NetworkException] on network error
  Future<void> logout();

  /// Get current authenticated user
  /// Throws [ServerException] on server error
  /// Throws [NetworkException] on network error
  /// Throws [AuthenticationException] if not authenticated
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return AuthResponseModel.fromJson(data);
      } else {
        throw AuthenticationException(
          response.data['message'] ?? 'Login failed',
          'LOGIN_FAILED',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred during login');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return AuthResponseModel.fromJson(data);
      } else {
        throw ValidationException(
          response.data['message'] ?? 'Registration failed',
          'REGISTRATION_FAILED',
          response.data['errors'],
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred during registration');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await dioClient.post('/auth/logout');

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Logout failed',
          'LOGOUT_FAILED',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred during logout');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');

      if (response.data['success'] == true) {
        final userData = response.data['data']['user'];
        return UserModel.fromJson(userData);
      } else {
        throw AuthenticationException(
          response.data['message'] ?? 'Failed to get user data',
          'USER_DATA_FAILED',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred while getting user data');
    }
  }
}