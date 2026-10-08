import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const adapter = MihomoProxyAdapter();

  test('toDefinition emits Mihomo proxy keys', () {
    const node = FluxaNode(
      id: 'fluxa-1',
      name: 'example-vless',
      protocol: FluxaProtocol.vless,
      server: 'example.com',
      port: 443,
      credentials: {'uuid': '6ba85179-2d07-4d0f-a02f-3c4c5b5b5b5b'},
      tls: {'tls': true, 'servername': 'example.com'},
      transport: {'network': 'ws'},
    );

    expect(
      adapter.toDefinition(node),
      {
        'name': 'example-vless',
        'type': 'vless',
        'server': 'example.com',
        'port': 443,
        'uuid': '6ba85179-2d07-4d0f-a02f-3c4c5b5b5b5b',
        'tls': true,
        'servername': 'example.com',
        'network': 'ws',
      },
    );
  });

  test('fromDefinition rebuilds core fields', () {
    final node = adapter.fromDefinition(
      {
        'name': 'n1',
        'type': 'trojan',
        'server': '1.2.3.4',
        'port': 8443,
        'password': 'secret',
      },
      id: 'id-9',
    );

    expect(node.id, 'id-9');
    expect(node.name, 'n1');
    expect(node.protocol, FluxaProtocol.trojan);
    expect(node.server, '1.2.3.4');
    expect(node.port, 8443);
    expect(node.credentials['password'], 'secret');
  });
}
