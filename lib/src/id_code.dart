enum InvalidIDCode implements Exception {
  // ID is empty
  empty,
  // ID contain invalid characters
  invalidChar,
  // ID is too long
  tooLong;
}

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
  static const IDCode first = IDCode._(value: 0);
  static final idCharMin = '!'.codeUnits.first;
  static final idCharMax = '~'.codeUnits.first;
  static final idCharRange = idCharMax - idCharMin + 1;

  final int value;

  IDCode next() => IDCode._(value: value + 1);
}
