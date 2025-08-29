import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final String period;

  const LoadDashboardData({this.period = 'month'});

  @override
  List<Object?> get props => [period];
}

class RefreshDashboardData extends DashboardEvent {
  final String period;

  const RefreshDashboardData({this.period = 'month'});

  @override
  List<Object?> get props => [period];
}

class ChangeDashboardPeriod extends DashboardEvent {
  final String period;

  const ChangeDashboardPeriod({required this.period});

  @override
  List<Object?> get props => [period];
}