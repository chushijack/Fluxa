import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';

/// Parses `trojan://` share links.
class TrojanParser implements FluxaNodeParser {
  const TrojanParser();

  static final RegExp _scheme = RegExp(r'^trojan://', caseSensitive: false);

  @override
  bool canParse(String input) => _scheme.hasMatch(input.trim());

  @override
  FluxaNode parse(String input) {
    final trimmed = input.trim();
    final uri = Uri.parse(trimmed);
    if (uri.scheme.toLowerCase() != 'trojan') {
      throw FormatException('Not a trojan URI', trimmed);
    }

    final password = uri.userInfo;
    if (password.isEmpty) {
      throw FormatException('Trojan URI missing password', trimmed);
    }

    final host = uri.host;
    if (host.isEmpty) {
      throw FormatException('Trojan URI missing host', trimmed);
    }

    final port = uri.hasPort ? uri.port : 443;
    final query = uri.queryParameters;
    final tls = <String, dynamic>{'tls': true};
    final sni = query['sni'] ?? query['peer'];
    if (sni != null && sni.isNotEmpty) {
      tls['servername'] = sni;
    }
    final allowInsecure = query['allowInsecure'] ?? query['insecure'];
    if (allowInsecure == '1' || allowInsecure?.toLowerCase() == 'true') {
      tls['skip-cert-verify'] = true;
    }

    final name = uri.fragment.isNotEmpty
        ? Uri.decodeComponent(uri.fragment)
        : 'trojan-$host:$port';

    return FluxaNode(
      id: 'trojan-$host:$port-$password',
      name: name,
      protocol: FluxaProtocol.trojan,
      server: host,
      port: port,
      credentials: {'password': password},
      tls: tls,
      metadata: const {'importSource': 'trojan-uri'},
    );
  }
}
