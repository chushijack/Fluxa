import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const parser = Hysteria2Parser();

  test('parses hy2 link', () {
    const link = 'hy2://secret@1.2.3.4:443?sni=example.com#hy2-node';
    final node = parser.parse(link);
    expect(node.protocol, FluxaProtocol.hysteria2);
    expect(node.credentials['password'], 'secret');
    expect(node.tls['sni'], 'example.com');
    expect(node.name, 'hy2-node');
  });

  test('parses hysteria2 scheme alias', () {
    expect(parser.canParse('hysteria2://x@1.1.1.1:8443'), isTrue);
  });
}
