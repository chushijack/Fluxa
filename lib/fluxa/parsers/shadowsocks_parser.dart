import 'dart:convert';

import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `ss://` share links (SIP002 / legacy base64 userinfo).
class ShadowsocksParser implements FluxaNodeParser {
  const ShadowsocksParser();

  static final RegExp _scheme = RegExp(r'^ss://', caseSensitive: false);

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final uri = Uri.parse(trimmed);
    if (uri.scheme.toLowerCase() != 'ss') {
      throw FormatException('Not an ss URI', trimmed);
    }

    final (method, password) = _readCredentials(uri, trimmed);
    final host = uri.host;
    if (host.isEmpty) {
      throw FormatException('SS URI missing host', trimmed);
    }
    final port = uri.hasPort ? uri.port : 8388;

    final name = uri.fragment.isNotEmpty
        ? Uri.decodeComponent(uri.fragment)
        : 'ss-$host:$port';

    return FluxaNode(
      id: 'ss-$method@$host:$port',
      name: name,
      protocol: FluxaProtocol.shadowsocks,
      server: host,
      port: port,
      credentials: {'cipher': method, 'password': password},
      metadata: const {'importSource': 'ss-uri'},
    );
  }

  (String method, String password) _readCredentials(Uri uri, String raw) {
    if (uri.userInfo.isNotEmpty) {
      final parts = uri.userInfo.split(':');
      if (parts.length >= 2) {
        return (parts.first, parts.sublist(1).join(':'));
      }
    }

    final withoutScheme = raw.substring('ss://'.length);
    final at = withoutScheme.lastIndexOf('@');
    if (at == -1) {
      throw FormatException('SS URI missing credentials', raw);
    }
    final userInfo = withoutScheme.substring(0, at);
    final decoded = utf8.decode(base64.decode(_normalizeBase64(userInfo)));
    final parts = decoded.split(':');
    if (parts.length < 2) {
      throw FormatException('SS URI invalid credentials', raw);
    }
    return (parts.first, parts.sublist(1).join(':'));
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
