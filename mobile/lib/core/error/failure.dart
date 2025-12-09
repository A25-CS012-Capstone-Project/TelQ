import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
