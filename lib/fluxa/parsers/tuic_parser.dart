import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `tuic://` share links.
class TuicParser implements FluxaNodeParser {
  const TuicParser();

  static final RegExp _scheme = RegExp(r'^tuic://', caseSensitive: false);

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final uri = Uri.parse(trimmed);
    if (uri.scheme.toLowerCase() != 'tuic') {
      throw FormatException('Not a tuic URI', trimmed);
    }

    final host = uri.host;
    if (host.isEmpty) {
      throw FormatException('TUIC URI missing host', trimmed);
    }

    final port = uri.hasPort ? uri.port : 443;
    final (uuid, password) = _readAuth(uri);
    if (uuid.isEmpty || password.isEmpty) {
      throw FormatException('TUIC URI missing uuid/password', trimmed);
    }

    final query = uri.queryParameters;
    final name = uri.fragment.isNotEmpty
        ? Uri.decodeComponent(uri.fragment)
        : 'tuic-$host:$port';

    final credentials = <String, dynamic>{'uuid': uuid, 'password': password};

    final congestion =
        query['congestion_control'] ?? query['congestion-control'];
    if (congestion != null && congestion.isNotEmpty) {
      credentials['congestion-controller'] = congestion;
    }

    final alpn = query['alpn'];
    if (alpn != null && alpn.isNotEmpty) {
      credentials['alpn'] = alpn
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final tls = <String, dynamic>{};
    final sni = query['sni'] ?? query['peer'];
    if (sni != null && sni.isNotEmpty) {
      tls['sni'] = sni;
    }
    if (query['allow_insecure'] == '1' || query['insecure'] == '1') {
      tls['skip-cert-verify'] = true;
    }

    return FluxaNode(
      id: uuid,
      name: name,
      protocol: FluxaProtocol.tuic,
      server: host,
      port: port,
      credentials: credentials,
      tls: tls,
      metadata: const {'importSource': 'tuic-uri'},
    );
  }

  (String uuid, String password) _readAuth(Uri uri) {
    final userInfo = uri.userInfo;
    if (userInfo.isEmpty) {
      return ('', '');
    }
    final separator = userInfo.indexOf(':');
    if (separator == -1) {
      return (userInfo, '');
    }
    return (
      userInfo.substring(0, separator),
      userInfo.substring(separator + 1),
    );
  }
}
