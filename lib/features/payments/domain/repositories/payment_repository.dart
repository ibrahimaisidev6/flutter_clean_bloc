import 'package:dartz/dartz.dart';
import '../entities/payment.dart';
import '../entities/payment_enums.dart';
import '../../../../core/error/failures.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments({
    int page = 1,
    int perPage = 15,
    PaymentStatus? status,
    PaymentType? type,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, Payment>> getPaymentById(int id);

  Future<Either<Failure, Payment>> getPaymentDetail(int id);

  Future<Either<Failure, Payment>> createPayment(Payment payment);

  Future<Either<Failure, Payment>> updatePayment({
    required int id,
    String? title,
    double? amount,
    PaymentType? type,
    PaymentStatus? status,
    String? description,
    String? category,
    String? reference,
  });

  Future<Either<Failure, bool>> deletePayment(int id);

  Future<Either<Failure, Payment>> processPayment(int id);
}