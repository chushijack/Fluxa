import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `vless://` share links into [FluxaNode].
class VlessParser implements FluxaNodeParser {
  const VlessParser();

  static final RegExp _scheme = RegExp(r'^vless://', caseSensitive: false);

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final uri = Uri.parse(trimmed);
    if (uri.scheme.toLowerCase() != 'vless') {
      throw FormatException('Not a vless URI', trimmed);
    }

    final uuid = uri.userInfo;
    if (uuid.isEmpty) {
      throw FormatException('VLESS URI missing UUID', trimmed);
    }

    final host = uri.host;
    if (host.isEmpty) {
      throw FormatException('VLESS URI missing host', trimmed);
    }

    final port = uri.hasPort ? uri.port : 443;
    if (port < 1 || port > 65535) {
      throw FormatException('VLESS URI invalid port: $port', trimmed);
    }

    final query = uri.queryParameters;
    final name = _displayName(uri, host, port);
    final credentials = <String, dynamic>{'uuid': uuid};
    final tls = <String, dynamic>{};
    final transport = <String, dynamic>{};

    _applyFlow(query, credentials);
    _applySecurity(query, tls);
    _applyTransport(query, transport);

    return FluxaNode(
      id: uuid,
      name: name,
      protocol: FluxaProtocol.vless,
      server: host,
      port: port,
      credentials: credentials,
      tls: tls,
      transport: transport,
      metadata: {
        'importSource': 'vless-uri',
        if (uri.fragment.isNotEmpty) 'fragment': uri.fragment,
      },
    );
  }

  String _displayName(Uri uri, String host, int port) {
    if (uri.fragment.isNotEmpty) {
      return Uri.decodeComponent(uri.fragment);
    }
    return 'vless-$host:$port';
  }

  void _applyFlow(Map<String, String> query, Map<String, dynamic> credentials) {
    final flow = query['flow'];
    if (flow != null && flow.isNotEmpty) {
      credentials['flow'] = flow;
    }
  }

  void _applySecurity(Map<String, String> query, Map<String, dynamic> tls) {
    final security = query['security']?.toLowerCase();
    if (security == null || security.isEmpty || security == 'none') {
      return;
    }

    tls['tls'] = true;

    final sni = query['sni'] ?? query['peer'];
    if (sni != null && sni.isNotEmpty) {
      tls['servername'] = sni;
    }

    final fp = query['fp'];
    if (fp != null && fp.isNotEmpty) {
      tls['client-fingerprint'] = fp;
    }

    final alpn = query['alpn'];
    if (alpn != null && alpn.isNotEmpty) {
      tls['alpn'] = alpn.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    if (security == 'reality') {
      final publicKey = query['pbk'];
      final shortId = query['sid'];
      if (publicKey == null || publicKey.isEmpty) {
        throw const FormatException('VLESS reality link missing pbk');
      }
      tls['reality-opts'] = {
        'public-key': publicKey,
        if (shortId != null && shortId.isNotEmpty) 'short-id': shortId,
        if (query['spx'] != null && query['spx']!.isNotEmpty) 'spider-x': query['spx'],
      };
    }

    final allowInsecure = query['allowinsecure'] ?? query['insecure'];
    if (allowInsecure == '1' || allowInsecure?.toLowerCase() == 'true') {
      tls['skip-cert-verify'] = true;
    }
  }

  void _applyTransport(Map<String, String> query, Map<String, dynamic> transport) {
    final network = (query['type'] ?? 'tcp').toLowerCase();
    transport['network'] = network;

    switch (network) {
      case 'ws':
        transport['ws-opts'] = _wsOpts(query);
      case 'grpc':
        transport['grpc-opts'] = _grpcOpts(query);
      case 'http':
      case 'h2':
        transport['network'] = 'h2';
        transport['h2-opts'] = _h2Opts(query);
      case 'tcp':
        final headerType = query['headerType'] ?? query['headertype'];
        if (headerType != null &&
            headerType.isNotEmpty &&
            headerType.toLowerCase() != 'none') {
          transport['tcp-opts'] = {
            'header': {'type': headerType},
          };
        }
      default:
        break;
    }
  }

  Map<String, dynamic> _wsOpts(Map<String, String> query) {
    final path = query['path'];
    final host = query['host'];
    return {
      'path': path == null || path.isEmpty ? '/' : Uri.decodeComponent(path),
      if (host != null && host.isNotEmpty)
        'headers': {'Host': Uri.decodeComponent(host)},
    };
  }

  Map<String, dynamic> _grpcOpts(Map<String, String> query) {
    final serviceName = query['serviceName'] ?? query['service-name'] ?? '';
    return {
      'grpc-service-name': Uri.decodeComponent(serviceName),
      if (query['mode'] != null && query['mode']!.isNotEmpty)
        'mode': query['mode'],
    };
  }

  Map<String, dynamic> _h2Opts(Map<String, String> query) {
    final path = query['path'];
    final host = query['host'];
    return {
      if (path != null && path.isNotEmpty) 'path': Uri.decodeComponent(path),
      if (host != null && host.isNotEmpty) 'host': [Uri.decodeComponent(host)],
    };
  }
}
