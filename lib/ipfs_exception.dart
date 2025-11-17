/// Custom exception for IPFS operations
class IpfsException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const IpfsException(
    this.message, {
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('IpfsException: $message');
    if (statusCode != null) {
      buffer.write(' (Status Code: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal Error: $originalError');
    }
    return buffer.toString();
  }
}
