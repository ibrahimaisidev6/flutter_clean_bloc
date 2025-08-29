import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DashboardData>> getDashboardStats({String period = 'month'}) async {
    if (await networkInfo.isConnected) {
      try {
        final dashboardData = await remoteDataSource.getDashboardStats(period: period);
        return Right(dashboardData);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}