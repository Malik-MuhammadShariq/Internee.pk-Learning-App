import 'package:equatable/equatable.dart';

/// Base failure class for Clean Architecture error handling
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server / Network failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache / Local storage failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
