import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login user with email and password
  /// Returns [AuthResponse] with user data and token on success
  /// Returns [Failure] on error
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Register new user
  /// Returns [AuthResponse] with user data and token on success
  /// Returns [Failure] on error
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logout current user
  /// Clears stored token and user data
  /// Returns [Unit] on success
  /// Returns [Failure] on error
  Future<Either<Failure, Unit>> logout();

  /// Get current authenticated user
  /// Returns [User] if user is logged in
  /// Returns [Failure] if not authenticated or error
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is authenticated
  /// Returns true if user has valid token
  Future<bool> isAuthenticated();

  /// Get stored auth token
  /// Returns token string if available
  /// Returns null if no token stored
  Future<String?> getAuthToken();
}