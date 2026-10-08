import 'dart:convert';

import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const parser = VmessParser();

  test('parses base64 vmess payload', () {
    final json = {
      'v': '2',
      'ps': 'vmess-node',
      'add': '1.2.3.4',
      'port': '443',
      'id': '6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b',
      'aid': '0',
      'net': 'ws',
      'path': '/ws',
      'host': 'cdn.example.com',
      'tls': 'tls',
      'sni': 'example.com',
    };
    final link = 'vmess://${base64Encode(utf8.encode(jsonEncode(json)))}';

    final node = parser.parse(link);
    expect(node.protocol, FluxaProtocol.vmess);
    expect(node.name, 'vmess-node');
    expect(node.transport['network'], 'ws');
    expect(node.tls['servername'], 'example.com');
  });
}
