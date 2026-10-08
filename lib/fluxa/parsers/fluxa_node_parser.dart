import 'package:fl_clash/fluxa/models/fluxa_node.dart';

/// Parses external input (share links, QR text, and so on) into [FluxaNode].
abstract interface class FluxaNodeParser {
  bool canParse(String input);

  FluxaNode parse(String input);
}
