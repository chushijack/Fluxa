import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';

/// Fluxa domain model for a single proxy endpoint.
///
/// Intentionally independent from [CustomProxy] / FlClash persistence.
class FluxaNode {
  const FluxaNode({
    required this.id,
    required this.name,
    required this.protocol,
    required this.server,
    required this.port,
    this.credentials = const {},
    this.tls = const {},
    this.transport = const {},
    this.metadata = const {},
  });

  final String id;
  final String name;
  final FluxaProtocol protocol;
  final String server;
  final int port;

  /// Protocol-specific secrets and auth (for example `uuid`, `password`).
  final Map<String, dynamic> credentials;

  /// TLS-related Mihomo keys (for example `tls`, `servername`, `skip-cert-verify`).
  final Map<String, dynamic> tls;

  /// Transport layer (for example `network`, `ws-opts`, `grpc-opts`).
  final Map<String, dynamic> transport;

  /// Fluxa-only data (import source, tags, last latency, and so on).
  final Map<String, dynamic> metadata;

  FluxaNode copyWith({
    String? id,
    String? name,
    FluxaProtocol? protocol,
    String? server,
    int? port,
    Map<String, dynamic>? credentials,
    Map<String, dynamic>? tls,
    Map<String, dynamic>? transport,
    Map<String, dynamic>? metadata,
  }) {
    return FluxaNode(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      server: server ?? this.server,
      port: port ?? this.port,
      credentials: credentials ?? this.credentials,
      tls: tls ?? this.tls,
      transport: transport ?? this.transport,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FluxaNode &&
        other.id == id &&
        other.name == name &&
        other.protocol == protocol &&
        other.server == server &&
        other.port == port;
  }

  @override
  int get hashCode => Object.hash(id, name, protocol, server, port);
}
