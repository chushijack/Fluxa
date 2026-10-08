import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `hysteria2://` and `hy2://` share links.
class Hysteria2Parser implements FluxaNodeParser {
  const Hysteria2Parser();

  static final RegExp _scheme = RegExp(
    r'^(hysteria2|hy2)://',
    caseSensitive: false,
  );

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final uri = Uri.parse(trimmed);
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'hysteria2' && scheme != 'hy2') {
      throw FormatException('Not a hysteria2 URI', trimmed);
    }

    final host = uri.host;
    if (host.isEmpty) {
      throw FormatException('Hysteria2 URI missing host', trimmed);
    }

    final port = uri.hasPort ? uri.port : 443;
    final query = uri.queryParameters;
    final password = _readPassword(uri, query);
    if (password == null || password.isEmpty) {
      throw FormatException('Hysteria2 URI missing password/auth', trimmed);
    }

    final name = uri.fragment.isNotEmpty
        ? Uri.decodeComponent(uri.fragment)
        : 'hy2-$host:$port';

    final credentials = <String, dynamic>{'password': password};
    final obfs = query['obfs-password'] ?? query['obfs'];
    if (obfs != null && obfs.isNotEmpty) {
      credentials['obfs-password'] = obfs;
    }

    final tls = <String, dynamic>{};
    final sni = query['sni'] ?? query['peer'];
    if (sni != null && sni.isNotEmpty) {
      tls['sni'] = sni;
    }
    if (query['insecure'] == '1' || query['allowInsecure'] == '1') {
      tls['skip-cert-verify'] = true;
    }

    return FluxaNode(
      id: 'hy2-$host:$port-$password',
      name: name,
      protocol: FluxaProtocol.hysteria2,
      server: host,
      port: port,
      credentials: credentials,
      tls: tls,
      metadata: {
        'importSource': 'hysteria2-uri',
        if (scheme == 'hy2') 'uriScheme': 'hy2',
      },
    );
  }

  String? _readPassword(Uri uri, Map<String, String> query) {
    if (uri.userInfo.isNotEmpty) {
      return uri.userInfo;
    }
    return query['auth'] ?? query['password'];
  }
}
