// lib/features/payments/domain/usecases/process_payment_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class ProcessPaymentParams {
  final int id;

  const ProcessPaymentParams({required this.id});
}

class ProcessPaymentUseCase implements UseCase<Payment, ProcessPaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(ProcessPaymentParams params) async {
    return await repository.processPayment(params.id);
  }
}