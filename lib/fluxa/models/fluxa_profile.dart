import 'package:fl_clash/fluxa/models/fluxa_node.dart';

/// Lightweight Fluxa profile shell for future import/storage flows.
class FluxaProfile {
  const FluxaProfile({
    required this.id,
    required this.label,
    this.nodes = const [],
    this.metadata = const {},
  });

  final String id;
  final String label;
  final List<FluxaNode> nodes;
  final Map<String, dynamic> metadata;
}
