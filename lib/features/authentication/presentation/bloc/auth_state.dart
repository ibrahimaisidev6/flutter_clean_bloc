import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final String? code;
  final Map<String, List<String>>? validationErrors;

  const AuthError({
    required this.message,
    this.code,
    this.validationErrors,
  });

  @override
  List<Object?> get props => [message, code, validationErrors];

  bool get hasValidationErrors => validationErrors != null && validationErrors!.isNotEmpty;

  List<String> getFieldErrors(String field) {
    return validationErrors?[field] ?? [];
  }

  String get firstError {
    if (hasValidationErrors) {
      final firstField = validationErrors!.keys.first;
      final firstError = validationErrors![firstField]?.first;
      return firstError ?? message;
    }
    return message;
  }
}