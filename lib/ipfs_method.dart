part of 'ipfs_client.dart';

abstract class IpfsMethod {
  const IpfsMethod();

  static final String addPath = '/api/v0/add';
  static final String catPath = '/api/v0/cat';
  static final String pinAddPath = '/api/v0/pin/add';
  static final String pinRmPath = '/api/v0/pin/rm';
  static final String pinLsPath = '/api/v0/pin/ls';
  static final String idPath = '/api/v0/id';
  static final String versionPath = '/api/v0/version';
  static final String repoStatPath = '/api/v0/repo/stat';
  static final String swarmPeersPath = '/api/v0/swarm/peers';
  static final String statsBwPath = '/api/v0/stats/bw';
  static final String pubsubPubPath = '/api/v0/pubsub/pub';
  static final String pubsubSubPath = '/api/v0/pubsub/sub';
  static final String pubsubPeersPath = '/api/v0/pubsub/peers';
  static final String pubsubLsPath = '/api/v0/pubsub/ls';
  static final String filesCpPath = '/api/v0/files/cp';

  /// Add a file to IPFS
  Future<AddResponse> add(File file);

  /// Retrieve content from IPFS by CID
  Future<CatResponse> cat(String cid);

  /// Pin an object to local storage
  Future<PinResponse> pinAdd(String cid);

  /// Remove a pinned object from local storage
  Future<UnpinResponse> pinRm(String cid);

  /// List pinned objects
  Future<PinLsResponse> pinLs({String? cid, String? type});

  /// Get node information
  Future<IdResponse> id();

  /// Get IPFS version
  Future<VersionResponse> version();

  /// Get repository statistics
  Future<StatsResponse> repoStat();

  /// Publish a message to a pubsub topic
  Future<void> pubsubPublish(String topic, String message);

  /// List topics subscribed to
  Future<List<String>> pubsubLs();

  Future<String> fileCp(String source, String destination);
}
