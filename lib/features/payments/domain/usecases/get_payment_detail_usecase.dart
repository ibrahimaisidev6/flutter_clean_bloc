// lib/features/payments/domain/usecases/get_payment_detail_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetPaymentDetailParams {
  final int id;

  const GetPaymentDetailParams({required this.id});
}

class GetPaymentDetailUseCase implements UseCase<Payment, GetPaymentDetailParams> {
  final PaymentRepository repository;

  GetPaymentDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(GetPaymentDetailParams params) async {
    return await repository.getPaymentDetail(params.id);
  }
}
