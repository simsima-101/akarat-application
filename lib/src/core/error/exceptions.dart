// lib/src/core/error/exceptions.dart

/// Thrown when there's an error with local cache/storage operations
/// (e.g., SharedPreferences failure)
class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);

  @override
  String toString() {
    if (message == null) return 'CacheException';
    return 'CacheException: $message';
  }
}

/// Thrown when there's a server/network error
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);

  @override
  String toString() {
    if (message == null) return 'ServerException';
    return 'ServerException: $message';
  }
}

/// Thrown when authentication fails (invalid credentials, etc.)
class AuthenticationException implements Exception {
  final String? message;
  AuthenticationException([this.message]);

  @override
  String toString() {
    if (message == null) return 'AuthenticationException';
    return 'AuthenticationException: $message';
  }
}