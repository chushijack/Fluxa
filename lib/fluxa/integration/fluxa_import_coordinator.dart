import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fluxa/adapters/flclash_custom_proxy_adapter.dart';
import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const fluxaNodesProfileLabel = 'Fluxa Nodes';

const _minimalProfileYaml = '''
proxies: []
proxy-groups:
  - name: Fluxa
    type: select
    proxies: []
rules:
  - MATCH,Fluxa
''';

/// Persists imported [FluxaNode] instances into FlClash storage.
class FluxaImportCoordinator {
  FluxaImportCoordinator(this._ref);

  final Ref _ref;

  static const _adapter = FlClashCustomProxyAdapter();

  Future<void> importNode(FluxaNode node) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;

    await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        final profile = await _ensureFluxaNodesProfile();
        final custom = _adapter.toCustomProxy(node, id: snowflake.id);

        final errors = await _ref
            .read(coreHandlerProvider)
            .validateProxies([custom.definition]);
        if (errors.first.isNotEmpty) {
          throw MessageException(errors.first);
        }

        _ref.read(customProxiesProvider(profile.id).notifier).put(custom);
        _ref.read(currentProfileIdProvider.notifier).value = profile.id;
      },
      title: currentAppLocalizations.addProfile,
    );
  }

  Future<Profile> _ensureFluxaNodesProfile() async {
    final profiles = _ref.read(profilesProvider);
    for (final profile in profiles) {
      if (profile.label == fluxaNodesProfileLabel) {
        return profile;
      }
    }

    final bytes = Uint8List.fromList(utf8.encode(_minimalProfileYaml));
    final profile = await Profile.normal(label: fluxaNodesProfileLabel).saveFile(
      bytes,
      validate: (path) => _ref.read(coreHandlerProvider).validateConfig(path),
    );
    _ref.read(profilesActionProvider.notifier).putProfile(profile);
    return profile;
  }
}
