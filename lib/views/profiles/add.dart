import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:fl_clash/fluxa/integration/import_confirm.dart';
import 'package:fl_clash/fluxa/services/fluxa_node_import_service.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddProfilePage() {
  final context = globalState.navigatorKey.currentState!.context;
  showExtend(
    context,
    builder: (context) => CommonScaffold(
      title: context.appLocalizations.addProfile,
      body: AddProfileView(context: context),
    ),
  );
}

class AddProfileView extends ConsumerWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    unawaited(ref.read(profilesActionProvider.notifier).addProfileFormFile());
  }

  Future<void> _toScan(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (system.isDesktop) {
      unawaited(profilesAction.addProfileFormQrCode());
      return;
    }
    final capture = await BaseNavigator.push<ImportCaptureResult>(
      context,
      const ScanPage(),
    );
    if (capture != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(profilesAction.importCaptureResult(capture));
      });
    }
  }

  Future<void> _importFromClipboard(WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final capture = await readImportCaptureFromClipboard();
    if (!context.mounted) {
      return;
    }
    if (capture == null) {
      final empty = await Clipboard.getData(Clipboard.kTextPlain);
      final message = empty?.text?.trim().isEmpty ?? true
          ? appLocalizations.clipboardImportEmpty
          : appLocalizations.clipboardImportInvalid;
      await dialogs.showMessage(
        title: appLocalizations.addProfile,
        message: TextSpan(text: message),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    final confirmed = await confirmImportCapture(context, capture);
    if (!confirmed) {
      return;
    }
    unawaited(
      ref.read(profilesActionProvider.notifier).importCaptureResult(capture),
    );
  }

  Future<void> _toAdd(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final reservedLabels = ref.read(
      appProviderLabelsProvider(ProviderKind.proxy),
    );
    final res = await dialogs.showNamedUrlInput(
      title: appLocalizations.importFromURL,
      labelValidator: (value) {
        if (reservedLabels.contains(value?.trim())) {
          return appLocalizations.existsTip(appLocalizations.name);
        }
        return null;
      },
      urlValidator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip('').trim();
        }
        if (value.isUrl) {
          return null;
        }
        if (FluxaNodeImportService.withDefaultParsers().canImport(value)) {
          return null;
        }
        return appLocalizations.urlTip('').trim();
      },
    );
    if (res != null) {
      final capture = resolveImportCaptureFromTexts([res.url]);
      if (capture != null) {
        unawaited(profilesAction.importCaptureResult(capture));
      } else {
        unawaited(profilesAction.addProfileFormURL(res.url, label: res.label));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      padding: EdgeInsets.only(top: context.contentTopPadding, bottom: 16),
      children: [
        ListItem(
          leading: const GlyphIcon(AppGlyphs.qrCode),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: () => _toScan(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.paste),
          title: Text(appLocalizations.importFromClipboard),
          subtitle: Text(appLocalizations.importFromClipboardDesc),
          onTap: () => _importFromClipboard(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.importFile),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: () => _handleAddProfileFormFile(ref),
        ),
        ListItem(
          leading: const GlyphIcon(AppGlyphs.cloudDownload),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: () => _toAdd(ref),
        ),
      ],
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final _urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: _urlController,
              decoration: InputDecoration(labelText: appLocalizations.url),
            ),
          ],
        ),
      ),
    );
  }
}
