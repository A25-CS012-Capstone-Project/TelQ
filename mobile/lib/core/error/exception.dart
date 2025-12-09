class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);
}

class ConnectionException implements Exception {
  final String message;
  ConnectionException([this.message = 'No internet connection']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
}

class AlreadyExistsException implements Exception {
  final String message;
  AlreadyExistsException([this.message = 'Already exists']);
}
