// lib/features/payments/domain/usecases/get_payments_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../entities/payment_enums.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetPaymentsParams {
  final int page;
  final int perPage;
  final PaymentStatus? status;
  final PaymentType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetPaymentsParams({
    required this.page,
    required this.perPage,
    this.status,
    this.type,
    this.startDate,
    this.endDate,
  });
}

class GetPaymentsUseCase implements UseCase<List<Payment>, GetPaymentsParams> {
  final PaymentRepository repository;

  GetPaymentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Payment>>> call(GetPaymentsParams params) async {
    return await repository.getPayments(
      page: params.page,
      perPage: params.perPage,
      status: params.status,
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}