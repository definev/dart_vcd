import 'scope_item/scope_item.dart';
import 'timescale.dart';

/// Structure containing the data from the header of a VCD file.
///
/// A [Header] can be parsed from VCD with [`Parser::parse_header`], or create an
/// empty [Header] with [`Header::default`].
class Header {
  const Header({required this.date, required this.version, required this.timescale, required this.items});
  factory Header.defaultValue() => Header(date: null, version: null, timescale: null, items: []);

  /// The date of the simulation.
  final String? date;

  /// The version of the VCD file.
  final String? version;

  /// The timescale of the simulation.
  final Timescale? timescale;

  /// Top-level variables, scopes and comments
  final List<ScopeItem> items;

  Header copyWith({
    String? date,
    String? version,
    Timescale? timescale,
    List<ScopeItem>? items,
  }) {
    return Header(
      date: date ?? this.date,
      version: version ?? this.version,
      timescale: timescale ?? this.timescale,
      items: items ?? this.items,
    );
  }
}
