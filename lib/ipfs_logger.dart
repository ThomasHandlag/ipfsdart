part of 'ipfs_client.dart';
class IpfsLogger {
  final bool enableDebug;
  final bool enableInfo;
  final bool enableWarning;
  final bool enableError;

  const IpfsLogger({
    this.enableDebug = false,
    this.enableInfo = true,
    this.enableWarning = true,
    this.enableError = true,
  });

  /// Log debug messages
  void debug(String message, [Object? data]) {
    if (enableDebug) {
      _log('DEBUG', message, data);
    }
  }

  /// Log info messages
  void info(String message, [Object? data]) {
    if (enableInfo) {
      _log('INFO', message, data);
    }
  }

  /// Log warning messages
  void warning(String message, [Object? data]) {
    if (enableWarning) {
      _log('WARNING', message, data);
    }
  }

  /// Log error messages
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (enableError) {
      _log('ERROR', message, error);
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  void _log(String level, String message, [Object? data]) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [$level] $message');
    if (data != null) {
      print('  Data: $data');
    }
  }
}
