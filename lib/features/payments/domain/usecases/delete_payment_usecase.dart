// lib/features/payments/domain/usecases/delete_payment_usecase.dart
import 'package:dartz/dartz.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class DeletePaymentParams {
  final int id;

  const DeletePaymentParams({required this.id});
}

class DeletePaymentUseCase implements UseCase<bool, DeletePaymentParams> {
  final PaymentRepository repository;

  DeletePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeletePaymentParams params) async {
    return await repository.deletePayment(params.id);
  }
}