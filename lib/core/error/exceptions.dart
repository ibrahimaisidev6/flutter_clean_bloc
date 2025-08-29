/// Base class for all exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when there's a server error
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Exception thrown when there's a cache error
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Exception thrown when there's a network error
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

/// Exception thrown when user is not authorized
class AuthorizationException extends AppException {
  const AuthorizationException(super.message, [super.code]);
}

/// Exception thrown when data validation fails
class ValidationException extends AppException {
  final String? field;
  final Map<String, List<String>>? errors;
  
  const ValidationException(super.message, [super.code, this.field, this.errors]);
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// Exception thrown when there's a timeout
class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.code]);
}

/// Exception thrown when file operations fail
class FileException extends AppException {
  const FileException(super.message, [super.code]);
}

/// Exception thrown when parsing fails
class ParsingException extends AppException {
  const ParsingException(super.message, [super.code]);
}