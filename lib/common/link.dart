import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:fl_clash/fluxa/integration/share_link_scan.dart';
import 'package:flutter/foundation.dart';

import 'print.dart';
import 'protocol.dart';

export 'package:fl_clash/fluxa/integration/share_link_scan.dart'
    show
        isFluxaShareLinkText,
        profileUrlFromQrCodes,
        resolveImportCaptureFromTexts;

typedef ImportCaptureCallback = void Function(ImportCaptureResult result);

class LinkManager {
  static LinkManager? _instance;
  StreamSubscription? subscription;
  Uri? _pendingUri;

  LinkManager._internal();

  @visibleForTesting
  Stream<Uri> Function() uriLinkStream = () => AppLinks().uriLinkStream;

  /// Linux argv: the gtk plugin hooks GApplication too late to see it.
  void seedInitialLink(List<String> args) {
    for (final arg in args) {
      final uri = Uri.tryParse(arg);
      if (uri == null) {
        continue;
      }
      if (protocolSchemes.contains(uri.scheme) || isFluxaShareLinkText(arg)) {
        _pendingUri = uri;
        return;
      }
    }
  }

  Future<void> initAppLinksListen(ImportCaptureCallback callback) async {
    commonPrint.log('initAppLinksListen');
    destroy();
    subscription = uriLinkStream().listen((uri) {
      _handle(uri, callback);
    });
    final pending = _pendingUri;
    _pendingUri = null;
    if (pending != null) {
      _handle(pending, callback);
    }
  }

  void _handle(Uri uri, ImportCaptureCallback callback) {
    commonPrint.log('onAppLink: $uri');
    final capture = resolveImportCaptureFromTexts([uri.toString()]);
    if (capture != null) {
      callback(capture);
      return;
    }
    final installUrl = installConfigUrlFromUri(uri)?.trim();
    if (installUrl != null) {
      callback(SubscriptionImportCapture(installUrl));
    }
  }

  void destroy() {
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
