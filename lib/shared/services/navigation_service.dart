import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/payments/presentation/pages/payment_detail_page.dart';
import '../../features/payments/presentation/pages/create_payment_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../widgets/main_layout.dart';
import '../../injection_container.dart' as di;

/// Service for managing app navigation using GoRouter
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  late final GoRouter _router;

  NavigationService() {
    final authBloc = di.sl<AuthBloc>();
    
    _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;
        
        debugPrint('NavigationService redirect: ${authState.runtimeType} -> $location');
        
        // Cas 1 : Splash en cours de chargement
        if (authState is AuthLoading && location == '/splash') {
          return null;
        }
        
        // Cas 2 : Utilisateur authentifié
        if (authState is AuthAuthenticated) {
          if (location == '/login' || location == '/register' || location == '/splash') {
            debugPrint('Redirecting authenticated user to dashboard');
            return '/dashboard';
          }
        }
        
        // Cas 3 : Utilisateur non authentifié
        if (authState is AuthUnauthenticated) {
          if (location != '/login' && location != '/register') {
            debugPrint('Redirecting unauthenticated user to login');
            return '/login';
          }
        }
        
        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      routes: [
        // Splash
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Authentication
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Dashboard
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const MainLayout(initialIndex: 0),
        ),
        
        // Payments
        GoRoute(
          path: '/payments',
          name: 'payments',
          builder: (context, state) => const MainLayout(initialIndex: 1),
          routes: [
            GoRoute(
              path: '/create',
              name: 'create-payment',
              builder: (context, state) => const CreatePaymentPage(),
            ),
            GoRoute(
              path: '/:id',
              name: 'payment-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PaymentDetailPage(paymentId: id);
              },
            ),
          ],
        ),

        // Historique
        GoRoute(
          path: '/history',
          name: 'history',
          builder: (context, state) => const MainLayout(initialIndex: 2),
        ),

        // Profil
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const MainLayout(initialIndex: 3),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GoRouter get router => _router;

  // Navigation helpers
  void goToLogin() => _router.go('/login');
  void goToRegister() => _router.go('/register');
  void goToDashboard() => _router.go('/dashboard');
  void goToPayments() => _router.go('/payments');
  void goToCreatePayment() => _router.go('/payments/create');
  void goToPaymentDetail(String paymentId) => _router.go('/payments/$paymentId');
  void goToHistory() => _router.go('/history');
  void goToProfile() => _router.go('/profile');

  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  BuildContext? get currentContext => navigatorKey.currentContext;

  void showSnackBar(String message, {bool isError = false}) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showErrorSnackBar(String message) => showSnackBar(message, isError: true);

  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final context = currentContext;
    if (context == null) return null;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/// Classe helper pour écouter les changements de stream AuthBloc
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      debugPrint('GoRouterRefreshStream: Auth state changed, notifying GoRouter');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
