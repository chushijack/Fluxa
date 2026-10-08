/// Fluxa product branding (names, links, assets).
abstract final class FluxaBrand {
  static const productName = 'Fluxa';

  /// Desktop Mihomo core binary base name (`.exe` on Windows).
  static const coreBinaryName = 'FluxaCore';

  /// Desktop Helper binary / Windows service base name.
  static const helperServiceName = 'FluxaHelperService';

  static const helperProtocolHeader = 'x-fluxa-helper-protocol';

  static const linuxHelperSystemdUnit = 'fluxa-helper';

  static const originRepository = 'chushijack/Fluxa';

  static const upstreamRepository = 'chen08209/FlClash';

  static const logoAsset = 'assets/images/fluxa/icon.png';

  static const upstreamCoreUrl =
      'https://github.com/chen08209/Clash.Meta/tree/FlClash';

  static const gplLicenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html';

  static const licensesTreeUrl =
      'https://github.com/chushijack/Fluxa/tree/main/LICENSES';

  static String originProjectUrl() => 'https://github.com/$originRepository';

  static String upstreamProjectUrl() =>
      'https://github.com/$upstreamRepository';
}
