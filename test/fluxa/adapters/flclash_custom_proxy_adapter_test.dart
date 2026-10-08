import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const adapter = FlClashCustomProxyAdapter();

  test('roundtrip through CustomProxy definition', () {
    const node = FluxaNode(
      id: 'fluxa-roundtrip',
      name: 'ss-node',
      protocol: FluxaProtocol.shadowsocks,
      server: '10.0.0.1',
      port: 8388,
      credentials: {'cipher': 'aes-256-gcm', 'password': 'p'},
    );

    final custom = adapter.toCustomProxy(node, id: 42);
    expect(custom.id, 42);
    expect(custom.definition['type'], 'ss');

    final restored = adapter.fromCustomProxy(custom);
    expect(restored.id, '42');
    expect(restored.metadata['flclashCustomProxyId'], 42);
    expect(restored.name, node.name);
    expect(restored.protocol, node.protocol);
    expect(restored.server, node.server);
    expect(restored.port, node.port);
    expect(restored.credentials['cipher'], 'aes-256-gcm');
  });
}
