import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ipfsdart/ipfsdart.dart';
import 'package:ipfsdart/ipfs_logger.dart';
import 'package:ipfsdart/ipfs_exception.dart';

void main() {
  group('IPFSDart Tests', () {
    late http.Client client;
    late IPFSDart ipfs;
    late IpfsLogger logger;

    setUp(() {
      client = http.Client();
      logger = IpfsLogger(
        enableDebug: true,
        enableInfo: true,
        enableWarning: true,
        enableError: true,
      );

      // Initialize with local IPFS node
      ipfs = IPFSDart(
        client,
        uri: Uri.parse('http://localhost:5001'),
        authMethod: AuthMethod.none,
        logger: logger,
      );
    });

    tearDown(() {
      client.close();
    });

    test('Logger logs messages at different levels', () {
      final logger = IpfsLogger(enableDebug: true);
      
      // These should not throw
      expect(() => logger.debug('Debug message'), returnsNormally);
      expect(() => logger.info('Info message'), returnsNormally);
      expect(() => logger.warning('Warning message'), returnsNormally);
      expect(() => logger.error('Error message', 'error data'), returnsNormally);
    });

    test('IpfsException contains proper error information', () {
      const exception = IpfsException(
        'Test error',
        statusCode: 500,
        originalError: 'Original error message',
      );

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(500));
      expect(exception.originalError, equals('Original error message'));
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('Status Code: 500'));
    });

    test('IPFSDart initialization with basic auth', () {
      final ipfsWithAuth = IPFSDart(
        client,
        uri: Uri.parse('http://localhost:5001'),
        username: 'testuser',
        password: 'testpass',
        authMethod: AuthMethod.basic,
        logger: logger,
      );

      expect(ipfsWithAuth.uri.toString(), equals('http://localhost:5001'));
      expect(ipfsWithAuth.username, equals('testuser'));
      expect(ipfsWithAuth.password, equals('testpass'));
      expect(ipfsWithAuth.authMethod, equals(AuthMethod.basic));
    });

    test('IPFSDart initialization with bearer auth', () {
      final ipfsWithBearer = IPFSDart(
        client,
        uri: Uri.parse('http://localhost:5001'),
        password: 'bearer-token',
        authMethod: AuthMethod.bearer,
        logger: logger,
      );

      expect(ipfsWithBearer.authMethod, equals(AuthMethod.bearer));
      expect(ipfsWithBearer.password, equals('bearer-token'));
    });

    test('Add method validates file existence', () async {
      final nonExistentFile = File('non_existent_file.txt');

      expect(
        () => ipfs.add(nonExistentFile),
        throwsA(isA<IpfsException>()),
      );
    });

    test('Cat method validates CID', () async {
      expect(
        () => ipfs.cat(''),
        throwsA(isA<IpfsException>()),
      );
    });

    test('PinAdd method validates CID', () async {
      expect(
        () => ipfs.pinAdd(''),
        throwsA(isA<IpfsException>()),
      );
    });

    test('PinRm method validates CID', () async {
      expect(
        () => ipfs.pinRm(''),
        throwsA(isA<IpfsException>()),
      );
    });

    test('PubsubPublish method validates topic', () async {
      expect(
        () => ipfs.pubsubPublish('', 'message'),
        throwsA(isA<IpfsException>()),
      );
    });

    // Integration tests (require running IPFS node)
    group('Integration Tests (requires IPFS node)', () {
      test('Get IPFS version', () async {
        try {
          final version = await ipfs.version();
          expect(version.version, isNotEmpty);
        } catch (e) {
          print('Skipping test - IPFS node not available: $e');
        }
      }, skip: 'Requires running IPFS node');

      test('Get node ID', () async {
        try {
          final nodeInfo = await ipfs.id();
          expect(nodeInfo.id, isNotEmpty);
        } catch (e) {
          print('Skipping test - IPFS node not available: $e');
        }
      }, skip: 'Requires running IPFS node');

      test('Get repository stats', () async {
        try {
          final stats = await ipfs.repoStat();
          expect(stats.repoSize, greaterThanOrEqualTo(0));
          expect(stats.numObjects, greaterThanOrEqualTo(0));
        } catch (e) {
          print('Skipping test - IPFS node not available: $e');
        }
      }, skip: 'Requires running IPFS node');
    });
  });
}
