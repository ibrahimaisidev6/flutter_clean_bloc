import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
/// Failures represent the left side of Either
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Failure when there's a server error
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Failure when there's a cache error
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Failure when there's a network error
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Failure when authentication fails
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

/// Failure when user is not authorized
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, [super.code]);
}

/// Failure when data validation fails
class ValidationFailure extends Failure {
  final String? field;
  final Map<String, List<String>>? errors;
  
  const ValidationFailure(super.message, [super.code, this.field, this.errors]);
  
  @override
  List<Object?> get props => [message, code, field, errors];
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

/// Failure when there's a timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.code]);
}

/// Failure when file operations fail
class FileFailure extends Failure {
  const FileFailure(super.message, [super.code]);
}

/// Failure when parsing fails
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.code]);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}