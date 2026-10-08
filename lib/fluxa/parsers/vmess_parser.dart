import 'dart:convert';

import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `vmess://` share links (V2RayN JSON payload, base64-encoded).
class VmessParser implements FluxaNodeParser {
  const VmessParser();

  static final RegExp _scheme = RegExp(r'^vmess://', caseSensitive: false);

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final payload = trimmed.substring(trimmed.indexOf('://') + 3);
    final jsonText = utf8.decode(base64.decode(_normalizeBase64(payload)));
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw FormatException('VMess payload is not a JSON object', trimmed);
    }
    final map = Map<String, dynamic>.from(decoded);

    final add = map['add']?.toString();
    final port = int.tryParse(map['port']?.toString() ?? '');
    final id = map['id']?.toString();
    if (add == null ||
        add.isEmpty ||
        port == null ||
        port < 1 ||
        port > 65535 ||
        id == null ||
        id.isEmpty) {
      throw FormatException('VMess payload missing add/port/id', map);
    }

    final name = map['ps']?.toString().trim();
    final network = map['net']?.toString() ?? 'tcp';
    final credentials = <String, dynamic>{
      'uuid': id,
      'alterId': int.tryParse(map['aid']?.toString() ?? '') ?? 0,
    };

    final tls = <String, dynamic>{};
    if (map['tls']?.toString() == 'tls') {
      tls['tls'] = true;
      final sni = map['sni']?.toString();
      if (sni != null && sni.isNotEmpty) {
        tls['servername'] = sni;
      }
    }

    final transport = <String, dynamic>{'network': network};
    switch (network) {
      case 'ws':
        transport['ws-opts'] = {
          'path': map['path']?.toString() ?? '/',
          if (map['host']?.toString().isNotEmpty == true)
            'headers': {'Host': map['host']},
        };
      case 'grpc':
        transport['grpc-opts'] = {
          'grpc-service-name': map['path']?.toString() ?? '',
        };
      default:
        break;
    }

    return FluxaNode(
      id: id,
      name: name == null || name.isEmpty ? 'vmess-$add:$port' : name,
      protocol: FluxaProtocol.vmess,
      server: add,
      port: port,
      credentials: credentials,
      tls: tls,
      transport: transport,
      metadata: const {'importSource': 'vmess-uri'},
    );
  }

  String _normalizeBase64(String value) {
    final normalized = value.replaceAll('-', '+').replaceAll('_', '/');
    final padding = normalized.length % 4;
    if (padding == 0) {
      return normalized;
    }
    return normalized.padRight(normalized.length + (4 - padding), '=');
  }
}
