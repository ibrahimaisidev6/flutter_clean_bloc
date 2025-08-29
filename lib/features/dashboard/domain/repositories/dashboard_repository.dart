import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_data.dart';

abstract class DashboardRepository {
  /// Get dashboard statistics and data
  /// Returns [DashboardData] with stats, recent payments, and chart data
  /// Returns [Failure] on error
  Future<Either<Failure, DashboardData>> getDashboardStats({String period = 'month'});
}