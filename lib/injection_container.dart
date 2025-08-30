import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/navigation_service.dart';

// Authentication imports
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/register_usecase.dart';
import 'features/authentication/domain/usecases/logout_usecase.dart';
import 'features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

// Dashboard imports
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Payments imports
import 'features/payments/data/datasources/payment_remote_data_source.dart';
import 'features/payments/data/repositories/payment_repository_impl.dart';
import 'features/payments/domain/repositories/payment_repository.dart';
import 'features/payments/domain/usecases/get_payments_usecase.dart';
import 'features/payments/domain/usecases/get_payment_detail_usecase.dart';
import 'features/payments/domain/usecases/create_payment_usecase.dart';
import 'features/payments/domain/usecases/update_payment_usecase.dart';
import 'features/payments/domain/usecases/delete_payment_usecase.dart';
import 'features/payments/domain/usecases/process_payment_usecase.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'features/payments/presentation/bloc/payment_list_bloc.dart';

// History imports
import 'features/history/data/datasources/history_remote_data_source.dart';
import 'features/history/data/repositories/history_repository_impl.dart'; // Changed: Import implementation
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_history_usecase.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

// Profile imports
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart'; // Changed: Import implementation
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => Connectivity());

  //! Services
  sl.registerLazySingleton(() => StorageService());

  //! Features - Authentication
  await _initAuth();

  //! Features - Dashboard
  await _initDashboard();

  //! Features - Payments
  await _initPayments();

  //! Features - History
  await _initHistory();

  //! Features - Profile
  await _initProfile();

  //! Navigation Service - DOIT être initialisé APRÈS AuthBloc
  sl.registerLazySingleton(() => NavigationService());
}

Future<void> _initAuth() async {
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Bloc - Singleton (pour que AuthBloc soit unique dans l'app)
  sl.registerLazySingleton(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        storageService: sl(),
        dioClient: sl(),
      ));
}

Future<void> _initDashboard() async {
  // Bloc
  sl.registerFactory(() => DashboardBloc(
        getDashboardStatsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );
}

Future<void> _initPayments() async {
  // Blocs
  sl.registerFactory(() => PaymentBloc(
        getPaymentDetailUseCase: sl(),
        createPaymentUseCase: sl(),
        updatePaymentUseCase: sl(),
        deletePaymentUseCase: sl(),
        processPaymentUseCase: sl(),
      ));

  sl.registerFactory(() => PaymentListBloc(
        getPaymentsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => DeletePaymentUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dioClient: sl()),
  );
}

Future<void> _initHistory() async {
  // Bloc
  sl.registerFactory(() => HistoryBloc(getHistoryUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));

  // Repository - Fixed: Use concrete implementation with proper constructor
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources - Fixed: Pass required dioClient parameter
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(dioClient: sl()),
  );
}

Future<void> _initProfile() async {
  // Bloc - Fixed: Use named parameters
  sl.registerFactory(() => ProfileBloc(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repository - Fixed: Use concrete implementation with proper constructor
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources - Fixed: Pass required dioClient parameter
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioClient: sl()),
  );
}