import 'package:fl_clash/fluxa/models/fluxa_node.dart';

/// Result of scanning or opening a share link / QR payload.
sealed class ImportCaptureResult {
  const ImportCaptureResult();
}

/// Airport subscription or remote config URL.
final class SubscriptionImportCapture extends ImportCaptureResult {
  const SubscriptionImportCapture(this.url);

  final String url;
}

/// Single-node share link parsed into Fluxa domain model.
final class NodeImportCapture extends ImportCaptureResult {
  const NodeImportCapture(this.node);

  final FluxaNode node;
}
