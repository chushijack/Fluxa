import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Asks the user to confirm a subscription or single-node import.
Future<bool> confirmImportCapture(
  BuildContext context,
  ImportCaptureResult capture,
) {
  final l10n = context.appLocalizations;
  return switch (capture) {
    SubscriptionImportCapture(:final url) => _confirmSubscription(context, url),
    NodeImportCapture(:final node) => dialogs.showMessage(
      title: l10n.addProfile,
      message: TextSpan(text: l10n.importNodeFromShareLinkTip(node.name)),
    ).then((value) => value == true),
  };
}

Future<bool> _confirmSubscription(BuildContext context, String url) async {
  final l10n = context.appLocalizations;
  final message = l10n.createProfileFromUrlTip(url);
  final parts = message.split(url);
  final result = await dialogs.showMessage(
    title: l10n.addProfile,
    message: TextSpan(
      children: [
        TextSpan(text: parts.first),
        TextSpan(
          text: url,
          style: TextStyle(
            color: context.colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: context.colorScheme.primary,
          ),
        ),
        if (parts.length > 1) TextSpan(text: parts.last),
      ],
    ),
  );
  return result == true;
}

/// Reads clipboard text and resolves it to an import capture, if supported.
Future<ImportCaptureResult?> readImportCaptureFromClipboard() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return resolveImportCaptureFromTexts([text]);
}
