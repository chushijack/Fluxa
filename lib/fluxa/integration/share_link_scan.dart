import 'package:fl_clash/common/protocol.dart';
import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:fl_clash/fluxa/services/fluxa_node_import_service.dart';

bool isFluxaShareLinkText(String text) {
  return FluxaNodeImportService.withDefaultParsers().canImport(text);
}

String? installConfigUrlFromUri(Uri uri) {
  return uri.host == 'install-config' ? uri.queryParameters['url'] : null;
}

/// Resolves QR text, clipboard, or deep-link payloads to subscription or node import.
ImportCaptureResult? resolveImportCaptureFromTexts(Iterable<String?> values) {
  final importService = FluxaNodeImportService.withDefaultParsers();

  for (final value in values) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      continue;
    }

    if (importService.canImport(text)) {
      return NodeImportCapture(importService.importFromText(text));
    }

    if (text.isUrl) {
      return SubscriptionImportCapture(text);
    }

    final uri = Uri.tryParse(text);
    if (uri == null || !protocolSchemes.contains(uri.scheme)) {
      continue;
    }

    final installUrl = installConfigUrlFromUri(uri)?.trim();
    if (installUrl != null && installUrl.isUrl) {
      return SubscriptionImportCapture(installUrl);
    }
  }
  return null;
}

/// Subscription URL only (FlClash legacy helper).
String? profileUrlFromQrCodes(Iterable<String?> values) {
  final result = resolveImportCaptureFromTexts(values);
  return switch (result) {
    SubscriptionImportCapture(:final url) => url,
    _ => null,
  };
}
