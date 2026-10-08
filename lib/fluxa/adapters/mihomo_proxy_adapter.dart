import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/models/fluxa_protocol.dart';

/// Maps between [FluxaNode] and Mihomo proxy definition maps (YAML JSON shape).
class MihomoProxyAdapter {
  const MihomoProxyAdapter();

  Map<String, dynamic> toDefinition(FluxaNode node) {
    return {
      'name': node.name,
      'type': node.protocol.wireName,
      'server': node.server,
      'port': node.port,
      ...node.credentials,
      ...node.tls,
      ...node.transport,
    };
  }

  FluxaNode fromDefinition(
    Map<String, dynamic> definition, {
    required String id,
    Map<String, dynamic> metadata = const {},
  }) {
    final name = definition['name']?.toString();
    final type = definition['type']?.toString();
    final server = definition['server']?.toString();
    final port = _readPort(definition['port']);
    final protocol = FluxaProtocol.tryParseWireName(type);

    if (name == null ||
        name.isEmpty ||
        protocol == null ||
        server == null ||
        server.isEmpty ||
        port == null) {
      throw FormatException('Incomplete Mihomo proxy definition', definition);
    }

    final reserved = {'name', 'type', 'server', 'port'};
    final credentials = <String, dynamic>{};
    for (final entry in definition.entries) {
      if (reserved.contains(entry.key)) {
        continue;
      }
      credentials[entry.key] = entry.value;
    }

    return FluxaNode(
      id: id,
      name: name,
      protocol: protocol,
      server: server,
      port: port,
      credentials: credentials,
      metadata: metadata,
    );
  }

  int? _readPort(Object? value) {
    return switch (value) {
      final int port => port,
      final num port => port.toInt(),
      final String port => int.tryParse(port),
      _ => null,
    };
  }
}
