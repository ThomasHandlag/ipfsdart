import 'dart:io';
import 'package:ipfsdart/ipfs_client.dart';

import '../test/local_test_set.dart';

void main() async {
  // Initialize IPFSDart with authentication and logger
  final ipfs = IpfsClient.init(
    uri: Uri.parse(url),
    authMethod: AuthMethod.bearer,
    password: bearerToken,
  );
  try {
    final response = await ipfs.getFile(
      '/ipfs/QmUmdPZwpB5yoXYJTGzj4A9UESuedHQSzzE6TiDjgNrbEx',
    );
    print('Get file response size: $response bytes');
  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('StackTrace: $stackTrace');
  }
}
