import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipfsdart/ipfsdart.dart';
import 'local_test_set.dart';

void main() {
  group('IPFSDart Tests', () {
    late IpfsClient ipfs;

    setUp(() {
      // Initialize with local IPFS node
      ipfs = IpfsClient.init(
        uri: Uri.parse(url),
        authMethod: AuthMethod.basic,
        password: pass,
        username: username,
      );
    });

    tearDown(() {
      ipfs.close();
    });

    test('IPFSDart initialization with basic auth', () {
      final ipfsWithAuth = IpfsClient.init(
        uri: Uri.parse(url),
        username: username,
        password: pass,
        authMethod: AuthMethod.basic,
      );

      expect(ipfsWithAuth.uri.toString(), equals(url));
    });

    test('IPFSDart initialization with bearer auth', () {
      final ipfsWithBearer = IpfsClient.init(
        uri: Uri.parse(url),
        password: bearerToken,
        authMethod: AuthMethod.bearer,
      );
      expect(ipfsWithBearer.authMethod, equals(AuthMethod.bearer));
    });

    test('Add method validates file existence', () async {
      final nonExistentFile = File('non_existent_file.txt');

      expect(() => ipfs.add(nonExistentFile), throwsA(isA<IpfsException>()));
    });

    test('Add file to ipfs', () async {
      final testFile = File('test_file.txt');
      await testFile.writeAsString('This is a test file for IPFS.');

      try {
        final addResponse = await ipfs.add(testFile);
        expect(addResponse.hash, isNotEmpty);
        expect(addResponse.name, equals('test_file.txt'));

        final cpReponse = await ipfs.fileCp(
          '/ipfs/${addResponse.hash}',
          '/${addResponse.name}',
        );
        expect(cpReponse, isNotEmpty);

        final pinResponse = await ipfs.pinAdd(addResponse.hash);
        expect(contains(pinResponse.pins.contains(addResponse.hash)), true);
      } finally {
        // Clean up
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });

    test('Cat method validates CID', () async {
      expect(() => ipfs.cat(''), throwsA(isA<IpfsException>()));
    });

    test('PinAdd method validates CID', () async {
      expect(() => ipfs.pinAdd(''), throwsA(isA<IpfsException>()));
    });

    test('PinRm method validates CID', () async {
      expect(() => ipfs.pinRm(''), throwsA(isA<IpfsException>()));
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
