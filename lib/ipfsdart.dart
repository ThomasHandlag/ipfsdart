import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart';
import 'package:ipfsdart/ipfs_exception.dart';
import 'package:ipfsdart/ipfs_logger.dart';
import 'package:ipfsdart/ipfs_method.dart';
import 'package:ipfsdart/ipfs_response.dart';

enum AuthMethod { none, basic, bearer }

class IPFSDart extends IpfsMethod {
  final Uri uri;
  final Client client;
  final String? username;
  final String? password;
  final AuthMethod authMethod;
  final IpfsLogger logger;

  const IPFSDart(
    this.client, {
    required this.uri,
    this.username,
    this.password,
    this.authMethod = AuthMethod.basic,
    this.logger = const IpfsLogger(),
  }) : assert(
         (authMethod == AuthMethod.basic &&
                 username != null &&
                 password != null) ||
             authMethod != AuthMethod.basic,
         'Username and password must be provided for basic authentication',
       ),
       assert(
         (authMethod == AuthMethod.bearer && password != null) ||
             authMethod != AuthMethod.bearer,
         'Token must be provided for bearer authentication',
       );

  Uri get publicGateway => uri.replace(path: '/ipfs/');

  /// Get authorization header based on auth method
  String get _authHeader => switch (authMethod) {
        AuthMethod.none => '',
        AuthMethod.basic =>
          'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        AuthMethod.bearer => 'Bearer $password',
      };

  /// Make a POST request with error handling and logging
  Future<Response> _makeRequest(
    String path,
    Map<String, String> headers, {
    Object? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final requestUri = uri.replace(
        path: path,
        queryParameters: queryParameters,
      );

      logger.debug('Making POST request to: $requestUri');

      if (_authHeader.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = _authHeader;
      }

      final response = await client.post(
        requestUri,
        headers: headers,
        body: body,
      );

      logger.debug('Response status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        logger.error(
          'Request failed with status ${response.statusCode}',
          response.body,
        );
        throw IpfsException(
          'Request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      return response;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Request error', e, stackTrace);
      throw IpfsException(
        'Failed to make request to $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Make a GET request with error handling and logging
  Future<Response> _makeGetRequest(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final requestUri = uri.replace(
        path: path,
        queryParameters: queryParameters,
      );

      logger.debug('Making GET request to: $requestUri');

      final headers = <String, String>{};
      if (_authHeader.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = _authHeader;
      }

      final response = await client.get(requestUri, headers: headers);

      logger.debug('Response status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        logger.error(
          'Request failed with status ${response.statusCode}',
          response.body,
        );
        throw IpfsException(
          'Request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      return response;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Request error', e, stackTrace);
      throw IpfsException(
        'Failed to make request to $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AddResponse> add(
    File file, {
    bool recursive = true,
    bool wrapWithDirectory = false,
    bool? quite,
    bool? quieter,
    bool? silent,
    bool? progress,
    bool? pin,
    String? pinName,
    String? toFiles,
    int? cidVersion,
    String? hash,
    bool? rawLeaves,
    String? chunker,
    bool? trickle,
    int? maxFileLinks,
    int? maxDirLinks,
    int? maxHamtFanout,
    bool? inline,
    int? inlineLimit,
    bool? nocopy,
    bool? fscache,
    bool? preserveMode,
    bool? preserveMTimes,
    Uint8? mode,
    Uint64? mtime,
    Uint8? mtimeNsecs,
  }) async {
    try {
      logger.info('Adding file to IPFS: ${file.path}');

      if (!await file.exists()) {
        logger.warning('File does not exist: ${file.path}');
        throw IpfsException('File does not exist: ${file.path}');
      }

      final multipart = MultipartRequest(
        'POST',
        uri.replace(path: IpfsMethod.addPath),
      );

      multipart.files.add(await MultipartFile.fromPath('file', file.path));

      if (_authHeader.isNotEmpty) {
        multipart.headers[HttpHeaders.authorizationHeader] = _authHeader;
      }

      final streamedResponse = await client.send(multipart);
      final result = await Response.fromStream(streamedResponse);

      if (result.statusCode != 200) {
        logger.error(
          'Failed to add file to IPFS',
          'Status: ${result.statusCode}, Body: ${result.body}',
        );
        throw IpfsException(
          'Failed to add file to IPFS: ${result.body}',
          statusCode: result.statusCode,
        );
      }

      final response = AddResponse.fromJson(
        jsonDecode(result.body) as Map<String, dynamic>,
      );

      logger.info('File added successfully with hash: ${response.hash}');
      return response;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error adding file', e, stackTrace);
      throw IpfsException(
        'Failed to add file: ${file.path}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<CatResponse> cat(String cid) async {
    try {
      logger.info('Retrieving content for CID: $cid');

      if (cid.isEmpty) {
        logger.warning('Empty CID provided');
        throw IpfsException('CID cannot be empty');
      }

      final response = await _makeGetRequest(
        IpfsMethod.catPath,
        queryParameters: {'arg': cid},
      );

      final contentType = response.headers['content-type'] ?? 'application/octet-stream';
      final data = response.bodyBytes;

      logger.info('Retrieved ${data.length} bytes for CID: $cid');

      return CatResponse(
        data: data,
        contentType: contentType,
        size: data.length,
      );
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error retrieving content', e, stackTrace);
      throw IpfsException(
        'Failed to retrieve content for CID: $cid',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<PinResponse> pinAdd(String cid) async {
    try {
      logger.info('Pinning CID: $cid');

      if (cid.isEmpty) {
        logger.warning('Empty CID provided for pinning');
        throw IpfsException('CID cannot be empty');
      }

      final response = await _makeRequest(
        IpfsMethod.pinAddPath,
        {},
        queryParameters: {'arg': cid},
      );

      final pinResponse = PinResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('Successfully pinned CID: $cid');
      return pinResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error pinning content', e, stackTrace);
      throw IpfsException(
        'Failed to pin CID: $cid',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UnpinResponse> pinRm(String cid) async {
    try {
      logger.info('Unpinning CID: $cid');

      if (cid.isEmpty) {
        logger.warning('Empty CID provided for unpinning');
        throw IpfsException('CID cannot be empty');
      }

      final response = await _makeRequest(
        IpfsMethod.pinRmPath,
        {},
        queryParameters: {'arg': cid},
      );

      final unpinResponse = UnpinResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('Successfully unpinned CID: $cid');
      return unpinResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error unpinning content', e, stackTrace);
      throw IpfsException(
        'Failed to unpin CID: $cid',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<PinLsResponse> pinLs({String? cid, String? type}) async {
    try {
      logger.info('Listing pinned objects${cid != null ? ' for CID: $cid' : ''}');

      final queryParams = <String, String>{};
      if (cid != null) queryParams['arg'] = cid;
      if (type != null) queryParams['type'] = type;

      final response = await _makeGetRequest(
        IpfsMethod.pinLsPath,
        queryParameters: queryParams,
      );

      final pinLsResponse = PinLsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('Found ${pinLsResponse.keys.length} pinned objects');
      return pinLsResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error listing pinned objects', e, stackTrace);
      throw IpfsException(
        'Failed to list pinned objects',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<IdResponse> id() async {
    try {
      logger.info('Fetching node information');

      final response = await _makeGetRequest(IpfsMethod.idPath);

      final idResponse = IdResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('Node ID: ${idResponse.id}');
      return idResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error fetching node information', e, stackTrace);
      throw IpfsException(
        'Failed to fetch node information',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<VersionResponse> version() async {
    try {
      logger.info('Fetching IPFS version');

      final response = await _makeGetRequest(IpfsMethod.versionPath);

      final versionResponse = VersionResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('IPFS Version: ${versionResponse.version}');
      return versionResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error fetching version', e, stackTrace);
      throw IpfsException(
        'Failed to fetch IPFS version',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<StatsResponse> repoStat() async {
    try {
      logger.info('Fetching repository statistics');

      final response = await _makeGetRequest(IpfsMethod.repoStatPath);

      final statsResponse = StatsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      logger.info('Repo size: ${statsResponse.repoSize} bytes, Objects: ${statsResponse.numObjects}');
      return statsResponse;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error fetching repository statistics', e, stackTrace);
      throw IpfsException(
        'Failed to fetch repository statistics',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> pubsubPublish(String topic, String message) async {
    try {
      logger.info('Publishing message to topic: $topic');

      if (topic.isEmpty) {
        logger.warning('Empty topic provided for pubsub publish');
        throw IpfsException('Topic cannot be empty');
      }

      await _makeRequest(
        IpfsMethod.pubsubPubPath,
        {},
        body: message,
        queryParameters: {'arg': topic},
      );

      logger.info('Message published successfully to topic: $topic');
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error publishing message', e, stackTrace);
      throw IpfsException(
        'Failed to publish message to topic: $topic',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>> pubsubLs() async {
    try {
      logger.info('Listing subscribed pubsub topics');

      final response = await _makeGetRequest(IpfsMethod.pubsubLsPath);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final topics = (data['Strings'] as List?)?.map((e) => e as String).toList() ?? [];

      logger.info('Found ${topics.length} subscribed topics');
      return topics;
    } catch (e, stackTrace) {
      if (e is IpfsException) rethrow;
      
      logger.error('Error listing pubsub topics', e, stackTrace);
      throw IpfsException(
        'Failed to list pubsub topics',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
