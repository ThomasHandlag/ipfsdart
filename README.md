# IPFS Dart

A comprehensive Dart package for interacting with IPFS (InterPlanetary File System) nodes.

## Features

### 🚀 Core IPFS Operations

- **File Management**: Add files to IPFS and retrieve content by CID
- **Pinning System**: Pin/unpin content and list all pinned objects
- **Node Information**: Access node ID, IPFS version, and repository statistics
- **PubSub Messaging**: Publish messages and manage subscribed topics

### 📝 Custom Logging System

- **Four Log Levels**: DEBUG, INFO, WARNING, ERROR
- **Configurable**: Enable/disable individual log levels
- **Detailed Tracking**: Includes timestamps, stack traces, and original errors
- **Production-Ready**: Monitor all IPFS operations in real-time

### 🔒 Flexible Authentication

- **Basic Authentication**: Username and password
- **Bearer Token**: Token-based authentication
- **No Authentication**: For open IPFS nodes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ipfsdart: ^0.0.1
  http: ^1.6.0
```

## Quick Start

```dart
import 'dart:io';
import 'package:ipfsdart/ipfsdart.dart';

void main() async {
  final ipfs = IpfsClient.init(
        uri: Uri.parse(url),
        authMethod: AuthMethod.basic,
        password: pass,
        username: username,
      );

      final testFile = File('test_file.txt');
      await testFile.writeAsString('This is a test file for IPFS.');

      try {
        final addResponse = await ipfs.add(testFile);

        final cpReponse = await ipfs.fileCp(
          '/ipfs/${addResponse.hash}',
          '/${addResponse.name}',
        );

        await ipfs.pinAdd(addResponse.hash);
      } catch (e) {
        ipfs.logger.debug(e);
      }
}
```

## API Methods

### File Operations

```dart
// Add file to IPFS
final response = await ipfs.add(File('example.txt'));

// Retrieve content by CID
final content = await ipfs.cat('QmYourCIDHere');
```

### Pinning Operations

```dart
// Pin content
await ipfs.pinAdd('QmYourCIDHere');

// Unpin content
await ipfs.pinRm('QmYourCIDHere');

// List all pinned objects
final pins = await ipfs.pinLs();
```

### Node Information

```dart
// Get node ID and information
final nodeInfo = await ipfs.id();

// Get IPFS version
final version = await ipfs.version();

// Get repository statistics
final stats = await ipfs.repoStat();
```

### PubSub

```dart
// Publish a message
await ipfs.pubsubPublish('my-topic', 'Hello IPFS!');

// List subscribed topics
final topics = await ipfs.pubsubLs();
```

## Authentication

### Basic Authentication

```dart
final ipfs = IPFSDart(
  client,
  uri: Uri.parse('http://localhost:5001'),
  username: 'your-username',
  password: 'your-password',
  authMethod: AuthMethod.basic,
  logger: logger,
);
```

### Bearer Token

```dart
final ipfs = IPFSDart(
  client,
  uri: Uri.parse('http://localhost:5001'),
  password: 'your-bearer-token',
  authMethod: AuthMethod.bearer,
  logger: logger,
);
```

## Custom Logging

Configure logging to track IPFS operations:

```dart
final logger = IpfsLogger(
  enableDebug: true,     // Detailed debugging information
  enableInfo: true,      // General operation messages
  enableWarning: true,   // Validation warnings
  enableError: true,     // Error messages with stack traces
);
```

### Log Output Example

```
[2025-11-17T10:30:45.123Z] [INFO] Adding file to IPFS: example.txt
[2025-11-17T10:30:45.456Z] [DEBUG] Making POST request to: http://localhost:5001/api/v0/add
[2025-11-17T10:30:46.789Z] [INFO] File added successfully with hash: QmHash123
```

## Error Handling

All methods throw `IpfsException` for IPFS-related errors:

```dart
try {
  final response = await ipfs.add(file);
} on IpfsException catch (e) {
  print('Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  print('Original Error: ${e.originalError}');
}
```

## Documentation

- **[API Documentation](API_DOCUMENTATION.md)** - Complete API reference
- **[Quick Reference](QUICK_REFERENCE.md)** - Quick lookup guide
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[Example](example/main.dart)** - Full working example

## Requirements

- Dart SDK: ^3.10.0
- Flutter: >=1.17.0
- Running IPFS node (local or remote)

## Testing

Run the test suite:

```bash
flutter test
```

Integration tests require a running IPFS node on `http://localhost:5001`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Additional Resources

- [IPFS Documentation](https://docs.ipfs.io/)
- [IPFS HTTP API](https://docs.ipfs.io/reference/http/api/)
- [Dart Packages](https://pub.dev/)
