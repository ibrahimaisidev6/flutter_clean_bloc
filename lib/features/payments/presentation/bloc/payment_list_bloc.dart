import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_payments_usecase.dart';
import 'payment_list_event.dart';
import 'payment_list_state.dart';

class PaymentListBloc extends Bloc<PaymentListEvent, PaymentListState> {
  final GetPaymentsUseCase getPaymentsUseCase;

  int _currentPage = 1;
  static const int _perPage = 15;

  PaymentListBloc({
    required this.getPaymentsUseCase,
  }) : super(const PaymentListInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<RefreshPayments>(_onRefreshPayments);
    on<FilterPayments>(_onFilterPayments);
    on<LoadMorePayments>(_onLoadMorePayments);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentListState> emit,
  ) async {
    emit(const PaymentListLoading());
    _currentPage = 1;

    final result = await getPaymentsUseCase(
      GetPaymentsParams(
        page: event.page,
        perPage: event.perPage,
        status: event.status,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(PaymentListError(message: failure.message)),
      (payments) => emit(PaymentListLoaded(
        payments: payments,
        hasReachedMax: payments.length < event.perPage,
        currentStatus: event.status,
        currentType: event.type,
        currentStartDate: event.startDate,
        currentEndDate: event.endDate,
      )),
    );
  }

  Future<void> _onRefreshPayments(
    RefreshPayments event,
    Emitter<PaymentListState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentListLoaded) {
      emit(PaymentListRefreshing(currentState.payments));
    } else {
      emit(const PaymentListLoading());
    }

    _currentPage = 1;

    final result = await getPaymentsUseCase(
      GetPaymentsParams(
        page: 1,
        perPage: _perPage,
        status: event.status,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(PaymentListError(
        message: failure.message,
        currentPayments: currentState is PaymentListLoaded ? currentState.payments : null,
      )),
      (payments) => emit(PaymentListLoaded(
        payments: payments,
        hasReachedMax: payments.length < _perPage,
        currentStatus: event.status,
        currentType: event.type,
        currentStartDate: event.startDate,
        currentEndDate: event.endDate,
      )),
    );
  }

  Future<void> _onFilterPayments(
    FilterPayments event,
    Emitter<PaymentListState> emit,
  ) async {
    emit(const PaymentListLoading());
    _currentPage = 1;

    final result = await getPaymentsUseCase(
      GetPaymentsParams(
        page: 1,
        perPage: _perPage,
        status: event.status,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(PaymentListError(message: failure.message)),
      (payments) => emit(PaymentListLoaded(
        payments: payments,
        hasReachedMax: payments.length < _perPage,
        currentStatus: event.status,
        currentType: event.type,
        currentStartDate: event.startDate,
        currentEndDate: event.endDate,
      )),
    );
  }

  Future<void> _onLoadMorePayments(
    LoadMorePayments event,
    Emitter<PaymentListState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentListLoaded && !currentState.hasReachedMax) {
      emit(PaymentListLoadingMore(currentState.payments));

      _currentPage++;

      final result = await getPaymentsUseCase(
        GetPaymentsParams(
          page: _currentPage,
          perPage: _perPage,
          status: currentState.currentStatus,
          type: currentState.currentType,
          startDate: currentState.currentStartDate,
          endDate: currentState.currentEndDate,
        ),
      );

      result.fold(
        (failure) => emit(PaymentListError(
          message: failure.message,
          currentPayments: currentState.payments,
        )),
        (newPayments) {
          final allPayments = List.of(currentState.payments)..addAll(newPayments);
          emit(PaymentListLoaded(
            payments: allPayments,
            hasReachedMax: newPayments.length < _perPage,
            currentStatus: currentState.currentStatus,
            currentType: currentState.currentType,
            currentStartDate: currentState.currentStartDate,
            currentEndDate: currentState.currentEndDate,
          ));
        },
      );
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<PaymentListState> emit,
  ) async {
    emit(const PaymentListLoading());
    _currentPage = 1;

    final result = await getPaymentsUseCase(
      const GetPaymentsParams(page: 1, perPage: _perPage),
    );

    result.fold(
      (failure) => emit(PaymentListError(message: failure.message)),
      (payments) => emit(PaymentListLoaded(
        payments: payments,
        hasReachedMax: payments.length < _perPage,
      )),
    );
  }
}