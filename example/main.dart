import 'dart:io';
import 'package:ipfsdart/ipfs_client.dart';

void main() async {
  // Initialize IPFSDart with authentication and logger
  final ipfs = IpfsClient.init(
    uri: Uri.parse('http://localhost:5001'),
    username: 'your-username',
    password: 'your-password',
    authMethod: AuthMethod.basic,
  );

  try {
    // Example 1: Get IPFS version
    print('\n=== Getting IPFS Version ===');
    final version = await ipfs.version();
    print('Version: ${version.version}');
    print('Commit: ${version.commit}');

    // Example 2: Get node information
    print('\n=== Getting Node Information ===');
    final nodeInfo = await ipfs.id();
    print('Node ID: ${nodeInfo.id}');
    print('Agent Version: ${nodeInfo.agentVersion}');
    print('Addresses: ${nodeInfo.addresses.take(3).join(', ')}...');

    // Example 3: Get repository statistics
    print('\n=== Getting Repository Statistics ===');
    final stats = await ipfs.repoStat();
    print('Repo Size: ${stats.repoSize} bytes');
    print('Number of Objects: ${stats.numObjects}');
    print('Storage Max: ${stats.storageMax} bytes');

    // Example 4: Add a file to IPFS
    print('\n=== Adding File to IPFS ===');
    final file = File('example.txt');
    
    // Create the file if it doesn't exist
    if (!await file.exists()) {
      await file.writeAsString('Hello IPFS from Dart!');
    }

    final addResponse = await ipfs.add(file);
    print('File added with hash: ${addResponse.hash}');
    print('File name: ${addResponse.name}');
    print('File size: ${addResponse.size}');

    // Example 5: Pin the added content
    print('\n=== Pinning Content ===');
    final pinResponse = await ipfs.pinAdd(addResponse.hash);
    print('Pinned: ${pinResponse.pins}');

    // Example 6: List pinned objects
    print('\n=== Listing Pinned Objects ===');
    final pinnedList = await ipfs.pinLs();
    print('Total pinned objects: ${pinnedList.keys.length}');
    
    // Show first 5 pinned objects
    final firstFive = pinnedList.keys.entries.take(5);
    for (final entry in firstFive) {
      print('  ${entry.key}: ${entry.value.type}');
    }

    // Example 7: Retrieve content from IPFS
    print('\n=== Retrieving Content ===');
    final catResponse = await ipfs.cat(addResponse.hash);
    print('Retrieved ${catResponse.size} bytes');
    print('Content type: ${catResponse.contentType}');
    print('Content: ${String.fromCharCodes(catResponse.data)}');

    // Example 8: Pubsub operations
    print('\n=== Pubsub Operations ===');
    
    // List subscribed topics
    final topics = await ipfs.pubsubLs();
    print('Subscribed topics: ${topics.isEmpty ? "None" : topics.join(", ")}');

    // Publish a message (will fail if pubsub is not enabled)
    try {
      await ipfs.pubsubPublish('test-topic', 'Hello from IPFS Dart!');
      print('Message published to test-topic');
    } catch (e) {
      print('Pubsub publish failed (pubsub might not be enabled): $e');
    }

    // Example 9: Unpin content
    print('\n=== Unpinning Content ===');
    final unpinResponse = await ipfs.pinRm(addResponse.hash);
    print('Unpinned: ${unpinResponse.pins}');

  } catch (e, stackTrace) {
    print('Error occurred: $e');
    print('StackTrace: $stackTrace');
  } 
}
