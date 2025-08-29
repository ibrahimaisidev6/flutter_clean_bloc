// lib/features/payments/presentation/bloc/payment_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentLoaded extends PaymentState {
  final Payment payment;

  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentCreating extends PaymentState {
  const PaymentCreating();
}

class PaymentCreated extends PaymentState {
  final Payment payment;

  const PaymentCreated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentUpdating extends PaymentState {
  final Payment currentPayment;

  const PaymentUpdating(this.currentPayment);

  @override
  List<Object?> get props => [currentPayment];
}

class PaymentUpdated extends PaymentState {
  final Payment payment;

  const PaymentUpdated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentDeleting extends PaymentState {
  final Payment currentPayment;

  const PaymentDeleting(this.currentPayment);

  @override
  List<Object?> get props => [currentPayment];
}

class PaymentDeleted extends PaymentState {
  const PaymentDeleted();
}

class PaymentProcessing extends PaymentState {
  final Payment currentPayment;

  const PaymentProcessing(this.currentPayment);

  @override
  List<Object?> get props => [currentPayment];
}

class PaymentProcessed extends PaymentState {
  final Payment payment;

  const PaymentProcessed(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentError extends PaymentState {
  final String message;
  final Payment? currentPayment; // Renommé pour correspondre au BLoC

  const PaymentError({
    required this.message,
    this.currentPayment,
  });

  @override
  List<Object?> get props => [message, currentPayment];
}