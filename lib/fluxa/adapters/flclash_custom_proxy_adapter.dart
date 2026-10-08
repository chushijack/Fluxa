import 'package:fl_clash/fluxa/adapters/mihomo_proxy_adapter.dart';
import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/models/clash_config.dart';

/// Bridge from Fluxa models into FlClash [CustomProxy] storage shape.
///
/// This is the only Fluxa module that should import FlClash clash models.
class FlClashCustomProxyAdapter {
  const FlClashCustomProxyAdapter({MihomoProxyAdapter? mihomo})
    : _mihomo = mihomo ?? const MihomoProxyAdapter();

  final MihomoProxyAdapter _mihomo;

  CustomProxy toCustomProxy(FluxaNode node, {int? profileId, int? id}) {
    final proxy = CustomProxy.fromDefinition(
      _mihomo.toDefinition(node),
      id: id,
    );
    if (profileId == null) {
      return proxy;
    }
    return proxy.copyWith(profileId: profileId);
  }

  FluxaNode fromCustomProxy(CustomProxy proxy) {
    final fluxaId = proxy.definition['fluxaId']?.toString();
    return _mihomo.fromDefinition(
      Map<String, dynamic>.from(proxy.definition),
      id: fluxaId ?? proxy.id.toString(),
      metadata: {
        if (proxy.profileId != null) 'profileId': proxy.profileId,
        'flclashCustomProxyId': proxy.id,
      },
    );
  }
}
