part of 'ipfs_client.dart';

final class AddResponse {
  final Uint64List bytes;
  final String hash;
  final String? mode;
  final Uint64List mTime;
  final int? mTimeNsecs;
  final String name;
  final String? size;

  const AddResponse({
    required this.bytes,
    required this.hash,
    required this.mode,
    required this.mTime,
    required this.mTimeNsecs,
    required this.name,
    required this.size,
  });

  factory AddResponse.fromJson(Map<String, dynamic> json) {
    return AddResponse(
      bytes: Uint64List.fromList((json['Bytes'] as List?)?.map((e) => e as int).toList() ?? []),
      hash: json['Hash'] as String,
      mode: json['Mode'] as String?,
      mTime: Uint64List.fromList((json['MTime'] as List?)?.map((e) => e as int).toList() ?? []),
      mTimeNsecs: json['MTimeNsecs'] as int?,
      name: json['Name'] as String,
      size: json['Size'] as String?,
    );
  }
}

final class CatResponse {
  final Uint8List data;
  final String contentType;
  final int size;

  const CatResponse({
    required this.data,
    required this.contentType,
    required this.size,
  });
}

final class PinResponse {
  final List<String> pins;

  const PinResponse({required this.pins});

  factory PinResponse.fromJson(Map<String, dynamic> json) {
    return PinResponse(
      pins: (json['Pins'] as List).map((e) => e as String).toList(),
    );
  }
}

final class UnpinResponse {
  final List<String> pins;

  const UnpinResponse({required this.pins});

  factory UnpinResponse.fromJson(Map<String, dynamic> json) {
    return UnpinResponse(
      pins: (json['Pins'] as List).map((e) => e as String).toList(),
    );
  }
}

final class PinLsResponse {
  final Map<String, PinInfo> keys;

  const PinLsResponse({required this.keys});

  factory PinLsResponse.fromJson(Map<String, dynamic> json) {
    final keys = <String, PinInfo>{};
    final keysJson = json['Keys'] as Map<String, dynamic>;
    keysJson.forEach((key, value) {
      keys[key] = PinInfo.fromJson(value as Map<String, dynamic>);
    });
    return PinLsResponse(keys: keys);
  }
}

final class PinInfo {
  final String type;

  const PinInfo({required this.type});

  factory PinInfo.fromJson(Map<String, dynamic> json) {
    return PinInfo(type: json['Type'] as String);
  }
}

final class IdResponse {
  final String id;
  final String publicKey;
  final List<String> addresses;
  final String agentVersion;
  final String protocolVersion;

  const IdResponse({
    required this.id,
    required this.publicKey,
    required this.addresses,
    required this.agentVersion,
    required this.protocolVersion,
  });

  factory IdResponse.fromJson(Map<String, dynamic> json) {
    return IdResponse(
      id: json['ID'] as String,
      publicKey: json['PublicKey'] as String,
      addresses: (json['Addresses'] as List).map((e) => e as String).toList(),
      agentVersion: json['AgentVersion'] as String,
      protocolVersion: json['ProtocolVersion'] as String,
    );
  }
}

final class VersionResponse {
  final String version;
  final String commit;
  final String repo;
  final String system;
  final String golang;

  const VersionResponse({
    required this.version,
    required this.commit,
    required this.repo,
    required this.system,
    required this.golang,
  });

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(
      version: json['Version'] as String,
      commit: json['Commit'] as String,
      repo: json['Repo'] as String,
      system: json['System'] as String,
      golang: json['Golang'] as String,
    );
  }
}

final class StatsResponse {
  final int repoSize;
  final int storageMax;
  final int numObjects;
  final String repoPath;
  final String version;

  const StatsResponse({
    required this.repoSize,
    required this.storageMax,
    required this.numObjects,
    required this.repoPath,
    required this.version,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      repoSize: json['RepoSize'] as int,
      storageMax: json['StorageMax'] as int,
      numObjects: json['NumObjects'] as int,
      repoPath: json['RepoPath'] as String,
      version: json['Version'] as String,
    );
  }
}
