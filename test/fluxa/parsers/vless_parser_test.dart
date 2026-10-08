import 'package:fl_clash/fluxa/fluxa.dart';
import 'package:test/test.dart';

void main() {
  const parser = VlessParser();

  test('canParse accepts vless scheme', () {
    expect(parser.canParse('vless://uuid@1.2.3.4:443'), isTrue);
    expect(parser.canParse('VLESS://uuid@1.2.3.4:443'), isTrue);
    expect(parser.canParse('vmess://x'), isFalse);
  });

  test('parses tcp + tls link', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@example.com:443'
        '?encryption=none&security=tls&sni=example.com&type=tcp'
        '#my-node';

    final node = parser.parse(link);

    expect(node.id, '6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b');
    expect(node.name, 'my-node');
    expect(node.protocol, FluxaProtocol.vless);
    expect(node.server, 'example.com');
    expect(node.port, 443);
    expect(node.credentials['uuid'], '6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b');
    expect(node.tls['tls'], isTrue);
    expect(node.tls['servername'], 'example.com');
    expect(node.transport['network'], 'tcp');
    expect(node.metadata['importSource'], 'vless-uri');
  });

  test('parses websocket transport', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@1.2.3.4:8443'
        '?security=tls&type=ws&path=%2Fvless&host=cdn.example.com';

    final node = parser.parse(link);
    expect(node.transport['network'], 'ws');
    expect(node.transport['ws-opts'], {
      'path': '/vless',
      'headers': {'Host': 'cdn.example.com'},
    });
  });

  test('parses reality security', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@1.2.3.4:443'
        '?security=reality&sni=www.example.com&pbk=abc&sid=def&type=tcp';

    final node = parser.parse(link);
    expect(node.tls['tls'], isTrue);
    expect(node.tls['reality-opts'], {'public-key': 'abc', 'short-id': 'def'});
  });

  test('parses IPv6 host', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@[2001:db8::1]:443?type=tcp';

    final node = parser.parse(link);
    expect(node.server, '2001:db8::1');
    expect(node.port, 443);
  });

  test('missing uuid throws', () {
    expect(
      () => parser.parse('vless://example.com:443'),
      throwsFormatException,
    );
  });
}
