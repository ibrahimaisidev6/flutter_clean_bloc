// lib/features/payments/presentation/bloc/payment_list_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_enums.dart';

abstract class PaymentListState extends Equatable {
  const PaymentListState();

  @override
  List<Object?> get props => [];
}

class PaymentListInitial extends PaymentListState {
  const PaymentListInitial();
}

class PaymentListLoading extends PaymentListState {
  const PaymentListLoading();
}

class PaymentListRefreshing extends PaymentListState {
  final List<Payment> currentPayments;

  const PaymentListRefreshing(this.currentPayments);

  @override
  List<Object?> get props => [currentPayments];
}

class PaymentListLoaded extends PaymentListState {
  final List<Payment> payments;
  final bool hasReachedMax;
  final PaymentStatus? currentStatus; // Changé en enum
  final PaymentType? currentType; // Changé en enum
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;

  const PaymentListLoaded({
    required this.payments,
    required this.hasReachedMax,
    this.currentStatus,
    this.currentType,
    this.currentStartDate,
    this.currentEndDate,
  });

  @override
  List<Object?> get props => [
        payments,
        hasReachedMax,
        currentStatus,
        currentType,
        currentStartDate,
        currentEndDate,
      ];

  PaymentListLoaded copyWith({
    List<Payment>? payments,
    bool? hasReachedMax,
    PaymentStatus? currentStatus,
    PaymentType? currentType,
    DateTime? currentStartDate,
    DateTime? currentEndDate,
  }) {
    return PaymentListLoaded(
      payments: payments ?? this.payments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentStatus: currentStatus ?? this.currentStatus,
      currentType: currentType ?? this.currentType,
      currentStartDate: currentStartDate ?? this.currentStartDate,
      currentEndDate: currentEndDate ?? this.currentEndDate,
    );
  }
}

class PaymentListLoadingMore extends PaymentListState {
  final List<Payment> currentPayments;

  const PaymentListLoadingMore(this.currentPayments);

  @override
  List<Object?> get props => [currentPayments];
}

class PaymentListError extends PaymentListState {
  final String message;
  final List<Payment>? currentPayments; // Ajouté le paramètre manquant

  const PaymentListError({
    required this.message,
    this.currentPayments,
  });

  @override
  List<Object?> get props => [message, currentPayments];
}