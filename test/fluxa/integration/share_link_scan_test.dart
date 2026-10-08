import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:fl_clash/fluxa/integration/share_link_scan.dart';
import 'package:test/test.dart';

void main() {
  test('resolves vless before subscription url', () {
    const link =
        'vless://6ba85179-2d07-4f0f-a02f-3c4c5b5b5b5b@1.2.3.4:443?type=tcp';

    final result = resolveImportCaptureFromTexts([link]);
    expect(result, isA<NodeImportCapture>());
  });

  test('still unwraps install-config links', () {
    final result = resolveImportCaptureFromTexts([
      'flclash://install-config?url=https%3A%2F%2Fexample.com%2Fa.yaml',
    ]);
    expect(result, isA<SubscriptionImportCapture>());
    expect((result! as SubscriptionImportCapture).url, 'https://example.com/a.yaml');
  });
}
