// lib/features/payments/presentation/bloc/payment_bloc.dart
// Version corrigée pour gérer les nouveaux événements

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_payment_detail_usecase.dart';
import '../../domain/usecases/create_payment_usecase.dart';
import '../../domain/usecases/update_payment_usecase.dart';
import '../../domain/usecases/delete_payment_usecase.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetPaymentDetailUseCase getPaymentDetailUseCase;
  final CreatePaymentUseCase createPaymentUseCase;
  final UpdatePaymentUseCase updatePaymentUseCase;
  final DeletePaymentUseCase deletePaymentUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;

  PaymentBloc({
    required this.getPaymentDetailUseCase,
    required this.createPaymentUseCase,
    required this.updatePaymentUseCase,
    required this.deletePaymentUseCase,
    required this.processPaymentUseCase,
  }) : super(const PaymentInitial()) {
    on<LoadPaymentDetail>(_onLoadPaymentDetail);
    on<CreatePayment>(_onCreatePayment);
    on<UpdatePayment>(_onUpdatePayment);
    on<DeletePayment>(_onDeletePayment);
    on<ProcessPayment>(_onProcessPayment);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  Future<void> _onLoadPaymentDetail(
    LoadPaymentDetail event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    final result = await getPaymentDetailUseCase(
      GetPaymentDetailParams(id: event.id),
    );

    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (payment) => emit(PaymentLoaded(payment)),
    );
  }

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentCreating());

    final result = await createPaymentUseCase(
      CreatePaymentParams(
        userId: event.userId,
        title: event.title,
        amount: event.amount,
        type: event.type,
        description: event.description,
        category: event.category,
        reference: event.reference,
        attachmentFile: event.attachmentFile,
      ),
    );

    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (payment) => emit(PaymentCreated(payment)),
    );
  }

  Future<void> _onUpdatePayment(
    UpdatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      emit(PaymentUpdating(currentState.payment));
    } else {
      emit(const PaymentLoading());
    }

    final result = await updatePaymentUseCase(
      UpdatePaymentParams(
        id: event.id,
        title: event.title,
        amount: event.amount,
        type: event.type,
        status: event.status,
        description: event.description,
        category: event.category,
        reference: event.reference,
      ),
    );

    result.fold(
      (failure) => emit(PaymentError(
        message: failure.message,
        currentPayment: currentState is PaymentLoaded ? currentState.payment : null,
      )),
      (payment) => emit(PaymentUpdated(payment)),
    );
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      emit(PaymentDeleting(currentState.payment));
    } else {
      emit(const PaymentLoading());
    }

    final result = await deletePaymentUseCase(
      DeletePaymentParams(id: event.id),
    );

    result.fold(
      (failure) => emit(PaymentError(
        message: failure.message,
        currentPayment: currentState is PaymentLoaded ? currentState.payment : null,
      )),
      (success) => emit(const PaymentDeleted()),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      emit(PaymentProcessing(currentState.payment));
    } else {
      emit(const PaymentLoading());
    }

    final result = await processPaymentUseCase(
      ProcessPaymentParams(id: event.id),
    );

    result.fold(
      (failure) => emit(PaymentError(
        message: failure.message,
        currentPayment: currentState is PaymentLoaded ? currentState.payment : null,
      )),
      (payment) => emit(PaymentProcessed(payment)),
    );
  }

  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<PaymentState> emit,
  ) {
    emit(const PaymentInitial());
  }
}