import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const parser = TuicParser();

  test('parses tuic link', () {
    const link =
        'tuic://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b:secret@example.com:443'
        '?congestion_control=cubic&sni=example.com#tuic-node';
    final node = parser.parse(link);
    expect(node.protocol, FluxaProtocol.tuic);
    expect(node.credentials['uuid'], '6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b');
    expect(node.credentials['password'], 'secret');
    expect(node.credentials['congestion-controller'], 'cubic');
    expect(node.name, 'tuic-node');
  });
}
