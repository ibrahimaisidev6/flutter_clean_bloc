// lib/features/payments/domain/usecases/update_payment_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../entities/payment_enums.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class UpdatePaymentParams {
  final int id;
  final String? title;
  final double? amount;
  final PaymentType? type;
  final PaymentStatus? status;
  final String? description;
  final String? category;
  final String? reference;

  const UpdatePaymentParams({
    required this.id,
    this.title,
    this.amount,
    this.type,
    this.status,
    this.description,
    this.category,
    this.reference,
  });
}

class UpdatePaymentUseCase implements UseCase<Payment, UpdatePaymentParams> {
  final PaymentRepository repository;

  UpdatePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(UpdatePaymentParams params) async {
    return await repository.updatePayment(
      id: params.id,
      title: params.title,
      amount: params.amount,
      type: params.type,
      status: params.status,
      description: params.description,
      category: params.category,
      reference: params.reference,
    );
  }
}
