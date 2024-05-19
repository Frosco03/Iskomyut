class DatabaseConnectionException implements Exception {
  final String message;

  DatabaseConnectionException(this.message);
}

class DatabaseOperationException implements Exception {
  final String message;

  DatabaseOperationException(this.message);
}