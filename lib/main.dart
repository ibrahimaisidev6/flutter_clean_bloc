import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // AJOUTÉ
import 'core/constants/app_constants.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'injection_container.dart' as di;
import 'shared/services/storage_service.dart';
import 'shared/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // AJOUTÉ: Initialiser les données de localisation française
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize services
  await di.sl<StorageService>().init();
  
  runApp(const PaymentApp());
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      key: UniqueKey(), // Ajouté pour éviter les problèmes de reconstruction
      value: di.sl<AuthBloc>(), // Suppression de ..add(AuthCheckRequested())
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Debug: Voir les changements d'état pour s'assurer que ça fonctionne
          debugPrint('AuthState in main.dart: ${state.runtimeType}');
          
          if (state is AuthUnauthenticated) {
            debugPrint('User logged out - redirection should happen automatically');
          } else if (state is AuthAuthenticated) {
            debugPrint('User authenticated: ${state.user.name}');
          }
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerConfig: di.sl<NavigationService>().router,
        ),
      ),
    );
  }
}