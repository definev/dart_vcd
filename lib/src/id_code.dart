/// Parse error for invalid ID code.
enum InvalidIDCode implements Exception {
  // ID is empty
  empty,
  // ID contain invalid characters
  invalidChar,
  // ID is too long
  tooLong;
}

/// An ID used within the file to refer to a particular variable.
final class IDCode {
  const IDCode._({required this.value});
  factory IDCode(String value) {
    int result = 0;
    if (value.isEmpty) {
      throw InvalidIDCode.empty;
    }
    final codeUnits = value.codeUnits;
    for (final codeUnit in codeUnits) {
      if (codeUnit < idCharMin || codeUnit > idCharMax) {
        throw InvalidIDCode.invalidChar;
      }
      final c = (codeUnit - idCharMin) + 1;
      result += c;
    }
    return IDCode._(value: result);
  }

  /// An arbitrary IdCode with a short representation.
  static const IDCode first = IDCode._(value: 0);
  static final idCharMin = '!'.codeUnits.first;
  static final idCharMax = '~'.codeUnits.first;
  static final idCharRange = idCharMax - idCharMin + 1;

  final int value;

  /// Returns the IdCode following this one in an arbitrary sequence.
  IDCode next() => IDCode._(value: value + 1);

  operator <=(IDCode other) => value <= other.value;
  operator >=(IDCode other) => value >= other.value;
  operator <(IDCode other) => value < other.value;
  operator >(IDCode other) => value > other.value;
  @override
  operator ==(Object? other) => other is IDCode ? value == other.value : false;

  @override
  String toString() {
    final codeUnits = <int>[];
    var v = value;
    while (v > 0) {
      final c = (v % idCharRange) + idCharMin - 1;
      codeUnits.add(c);
      v ~/= idCharRange;
    }
    return String.fromCharCodes(codeUnits.reversed);
  }

  @override
  int get hashCode => Object.hashAll([value]);
}
