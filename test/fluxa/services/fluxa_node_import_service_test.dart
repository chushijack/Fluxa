import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  final service = FluxaNodeImportService.withDefaultParsers();

  test('importFromText uses VlessParser', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@10.0.0.1:443?type=tcp#edge';

    final node = service.importFromText(link);
    expect(node.protocol, FluxaProtocol.vless);
    expect(node.name, 'edge');
  });

  test('unknown scheme throws FormatException', () {
    expect(
      () => service.importFromText('trojan://x'),
      throwsFormatException,
    );
  });

  test('roundtrip to Mihomo definition via adapter', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@gw.example.com:443'
        '?security=tls&sni=gw.example.com&type=tcp#gw';

    final node = service.importFromText(link);
    final definition = const MihomoProxyAdapter().toDefinition(node);

    expect(definition['type'], 'vless');
    expect(definition['uuid'], '6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b');
    expect(definition['tls'], isTrue);
    expect(definition['servername'], 'gw.example.com');
  });
}
