/// Data layer exception hierarchy.
///
/// These exceptions are INTERNAL to the data layer.
/// They must NEVER cross into the domain or presentation layers.
/// Repository implementations catch these and convert them to [Failure]
/// subtypes before returning [Result<T>].
sealed class DataException implements Exception {
  const DataException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Device has no internet, or the connection timed out.
final class NetworkException extends DataException {
  const NetworkException(super.message);
}

/// Server returned a non-2xx HTTP status code.
final class ServerException extends DataException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

/// Hive read or write operation failed.
final class CacheException extends DataException {
  const CacheException(super.message);
}

/// Requested resource does not exist locally or remotely.
final class NotFoundException extends DataException {
  const NotFoundException(super.message);
}

/// Mapper could not parse a DTO into a domain entity.
/// Thrown when required API fields are null or in an unexpected format.
/// Caught by [RepositoryCalls.safeRemoteRead] and converted to [DataParsingFailure].
final class DataParsingException extends DataException {
  const DataParsingException(super.message);
}
