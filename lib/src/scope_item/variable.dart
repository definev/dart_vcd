part of 'scope_item.dart';

enum VariableType {
  event,
  interger,
  parameter,
  real,
  reg,
  supply0,
  supply1,
  time,
  tri,
  triAnd,
  triOr,
  triReg,
  tri0,
  tri1,
  wAnd,
  wire,
  wOr,
  string;

  @override
  String toString() => name;
}

/// Index of a VCD variable reference: either a bit select index [index] or a range index [msb] to [lsb]
sealed class ReferenceIndex {
  const ReferenceIndex();
  factory ReferenceIndex.fromStr(String s) {
    final str = s.substring(1, s.length - 1);
    return switch (str.split(':')) {
      [final idx] => BitSelect(index: int.parse(idx)),
      [final msb, final lsb] => Range(msb: int.parse(msb), lsb: int.parse(lsb)),
      _ => throw Exception('Invalid reference index: $s'),
    };
  }

  @override
  String toString() => switch (this) {
        BitSelect(:final index) => '[$index]',
        Range(:final msb, :final lsb) => '[$msb:$lsb]',
      };
}

/// Single bit (e.g `[0]`)
class BitSelect extends ReferenceIndex {
  const BitSelect({required this.index});

  final int index;
}

/// Range of bits (e.g. `[7,0]`)
class Range extends ReferenceIndex {
  const Range({required this.msb, required this.lsb});

  final int msb;
  final int lsb;
}

/// [variable] - Variable
///
/// Information on a VCD variable as represented by a `$var` command.
class Variable extends ScopeItem {
  /// Create a [Variable].
  const Variable({
    required this.type,
    required this.size,
    required this.id,
    required this.reference,
    required this.index,
  });

  /// Type of variable.
  final VariableType type;

  /// Width in bits.
  final int size;

  /// Internal code used in value changes to link them back to this variable.
  ///
  /// Multiple variables can have the same [id] if they always have the same
  /// value.
  final IDCode id;

  /// Name of the variable.
  final String reference;

  /// Optional bit index or range associated with the [reference].
  final ReferenceIndex? index;
}
