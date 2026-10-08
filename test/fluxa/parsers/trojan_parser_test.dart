import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const parser = TrojanParser();

  test('parses trojan link', () {
    const link = 'trojan://secret@example.com:443?sni=example.com#edge';
    final node = parser.parse(link);
    expect(node.protocol, FluxaProtocol.trojan);
    expect(node.credentials['password'], 'secret');
    expect(node.tls['servername'], 'example.com');
    expect(node.name, 'edge');
  });
}
