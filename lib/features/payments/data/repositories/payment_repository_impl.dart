import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Payment>>> getPayments({
    int page = 1,
    int perPage = 15,
    PaymentStatus? status,
    PaymentType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final payments = await remoteDataSource.getPayments(
          page: page,
          perPage: perPage,
          status: status?.name, // Convertir enum en String
          type: type?.name, // Convertir enum en String
          startDate: startDate,
          endDate: endDate,
        );
        return Right(payments);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final payment = await remoteDataSource.getPaymentById(id);
        return Right(payment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentDetail(int id) async {
    // Implementation de la méthode manquante
    return getPaymentById(id);
  }

  @override
  Future<Either<Failure, Payment>> createPayment(Payment payment) async {
    if (await networkInfo.isConnected) {
      try {
        final createdPayment = await remoteDataSource.createPayment(
          amount: payment.amount,
          type: payment.type.name, // Convertir enum en String
          description: payment.description ?? '',
          reference: payment.reference,
          attachmentFile: payment.attachmentFile, title: '',
        );
        return Right(createdPayment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Payment>> updatePayment({
    required int id,
    String? title,
    double? amount,
    PaymentType? type,
    PaymentStatus? status,
    String? description,
    String? category,
    String? reference,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final payment = await remoteDataSource.updatePayment(
          id: id,
          amount: amount,
          type: type?.name, // Convertir enum en String
          status: status?.name, // Convertir enum en String
          description: description,
          reference: reference,
        );
        return Right(payment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code, e.field, e.errors));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePayment(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deletePayment(id);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Payment>> processPayment(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final payment = await remoteDataSource.processPayment(id);
        return Right(payment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(e.message, e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error: ${e.toString()}',
          '500',
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}