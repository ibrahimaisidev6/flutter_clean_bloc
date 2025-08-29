import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_data.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardRefreshing extends DashboardState {
  final DashboardData currentData;

  const DashboardRefreshing(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final String period;

  const DashboardLoaded({
    required this.data,
    required this.period,
  });

  @override
  List<Object?> get props => [data, period];
}

class DashboardError extends DashboardState {
  final String message;
  final DashboardData? currentData;

  const DashboardError({
    required this.message,
    this.currentData,
  });

  @override
  List<Object?> get props => [message, currentData];
}