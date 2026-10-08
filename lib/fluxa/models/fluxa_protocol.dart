/// Mihomo / Clash.Meta proxy `type` values used by Fluxa.
///
/// Kept in Fluxa layer so UI and parsers do not depend on FlClash models.
enum FluxaProtocol {
  shadowsocks('ss'),
  vmess('vmess'),
  vless('vless'),
  trojan('trojan'),
  hysteria('hysteria'),
  hysteria2('hysteria2'),
  tuic('tuic'),
  socks5('socks5'),
  http('http');

  const FluxaProtocol(this.wireName);

  final String wireName;

  static FluxaProtocol? tryParseWireName(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.toLowerCase();
    for (final protocol in FluxaProtocol.values) {
      if (protocol.wireName == normalized) {
        return protocol;
      }
    }
    return null;
  }
}
