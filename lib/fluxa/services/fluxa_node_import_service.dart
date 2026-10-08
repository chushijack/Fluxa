import 'package:fl_clash/fluxa/models/fluxa_node.dart';
import 'package:fl_clash/fluxa/parsers/fluxa_node_parser.dart';
import 'package:fl_clash/fluxa/parsers/vless_parser.dart';

/// Orchestrates share-link import into Fluxa nodes (storage wiring comes later).
class FluxaNodeImportService {
  FluxaNodeImportService({List<FluxaNodeParser>? parsers})
    : _parsers = List.unmodifiable(parsers ?? const []);

  /// Built-in parsers for phase 2 (extend as more protocols land).
  factory FluxaNodeImportService.withDefaultParsers() {
    return FluxaNodeImportService(
      parsers: const [
        VlessParser(),
      ],
    );
  }

  final List<FluxaNodeParser> _parsers;

  FluxaNode importFromText(String input) {
    final trimmed = input.trim();
    for (final parser in _parsers) {
      if (parser.canParse(trimmed)) {
        return parser.parse(trimmed);
      }
    }
    throw FormatException('No parser registered for input', trimmed);
  }
}
