import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ChangeDashboardPeriod>(_onChangeDashboardPeriod);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    
    final result = await getDashboardStatsUseCase(
      DashboardStatsParams(period: event.period),
    );
    
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (data) => emit(DashboardLoaded(data: data, period: event.period)),
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentState.data));
    } else {
      emit(const DashboardLoading());
    }
    
    final result = await getDashboardStatsUseCase(
      DashboardStatsParams(period: event.period),
    );
    
    result.fold(
      (failure) => emit(DashboardError(
        message: failure.message,
        currentData: currentState is DashboardLoaded ? currentState.data : null,
      )),
      (data) => emit(DashboardLoaded(data: data, period: event.period)),
    );
  }

  Future<void> _onChangeDashboardPeriod(
    ChangeDashboardPeriod event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentState.data));
    } else {
      emit(const DashboardLoading());
    }
    
    final result = await getDashboardStatsUseCase(
      DashboardStatsParams(period: event.period),
    );
    
    result.fold(
      (failure) => emit(DashboardError(
        message: failure.message,
        currentData: currentState is DashboardLoaded ? currentState.data : null,
      )),
      (data) => emit(DashboardLoaded(data: data, period: event.period)),
    );
  }
}