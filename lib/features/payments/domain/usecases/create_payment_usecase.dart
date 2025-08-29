// lib/features/payments/domain/usecases/create_payment_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../entities/payment_enums.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class CreatePaymentParams {
  final int userId;
  final String title;
  final double amount;
  final PaymentType type;
  final String? description;
  final String? category;
  final String? reference;

  const CreatePaymentParams({
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    this.description,
    this.category,
    this.reference,
  });
}

class CreatePaymentUseCase implements UseCase<Payment, CreatePaymentParams> {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(CreatePaymentParams params) async {
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch, // Temporaire, sera remplacé par l'ID de la DB
      userId: params.userId,
      title: params.title,
      amount: params.amount,
      type: params.type,
      status: PaymentStatus.pending, // Status par défaut
      description: params.description,
      category: params.category,
      reference: params.reference ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.createPayment(payment);
  }
}