import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase implements UseCase<DashboardData, DashboardStatsParams> {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardData>> call(DashboardStatsParams params) async {
    return await repository.getDashboardStats(period: params.period);
  }
}

class DashboardStatsParams extends Params {
  final String period;

  const DashboardStatsParams({this.period = 'month'});

  @override
  List<Object?> get props => [period];
}