import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart'; // AJOUT: Import DioClient
import '../../../../shared/services/storage_service.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final StorageService storageService;
  final DioClient dioClient; // AJOUT: Injection du DioClient

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.storageService,
    required this.dioClient, // AJOUT: Paramètre requis
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUserRequested>(_onUserRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authResponse) {
        // AJOUT: Définir le token dans les headers HTTP
        if (authResponse.token.isNotEmpty) {
          dioClient.setAuthToken(authResponse.token);
        }
        emit(AuthAuthenticated(authResponse.user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authResponse) {
        // AJOUT: Définir le token dans les headers HTTP
        if (authResponse.token.isNotEmpty) {
          dioClient.setAuthToken(authResponse.token);
        }
        emit(AuthAuthenticated(authResponse.user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    // AJOUT: Supprimer le token des headers HTTP
    dioClient.clearAuthToken();

    result.fold(
      (failure) {
        // Even if logout fails on server, we still consider user logged out locally
        emit(AuthUnauthenticated());
      },
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Check if we have a stored token
    final token = await storageService.getAuthToken();
    if (token == null || token.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    // AJOUT: Restaurer le token dans les headers HTTP
    dioClient.setAuthToken(token);

    // Try to get current user
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) {
        if (failure is AuthenticationFailure) {
          // Token is invalid, clear it
          storageService.clearAuthToken();
          storageService.clearUserData();
          dioClient.clearAuthToken(); // AJOUT: Supprimer des headers aussi
        }
        emit(AuthUnauthenticated());
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onUserRequested(
    AuthUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      emit(AuthLoading());

      final result = await getCurrentUserUseCase();

      result.fold(
        (failure) => emit(AuthError(
          message: failure.message,
          code: failure.code,
        )),
        (user) => emit(AuthAuthenticated(user)),
      );
    }
  }
}