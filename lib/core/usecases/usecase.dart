import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Base class for all use cases in the app
/// This follows the Clean Architecture principle where use cases
/// represent the business logic of the application
abstract class UseCase<Type, Params> {
  /// The main method that executes the use case
  /// Returns Either<Failure, Type> where:
  /// - Left side contains the failure
  /// - Right side contains the success result
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case for operations that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for parameters passed to use cases
abstract class Params {
  const Params();
}

/// Empty parameters for use cases that don't need any input
class NoParams extends Params {
  const NoParams();
}

/// Generic parameters class for simple data passing
class SimpleParams extends Params {
  final Map<String, dynamic> data;
  
  const SimpleParams(this.data);
  
  @override
  List<Object?> get props => [data];
}