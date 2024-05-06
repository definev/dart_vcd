import 'dart:typed_data';

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

int checkOverflow(int a) {
  int maxInt64 = 9007199254740991;
  int minInt64 = 9007199254740992;
  int b = 1; // You can replace this with the value you want to add

  if ((a > 0 && b > maxInt64 - a) || (a < 0 && b < minInt64 - a)) {
    throw InvalidIDCode.tooLong;
  } else {
    return a;
  }
}

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
  const IDCode.raw(this.value);
  factory IDCode(Uint8List value) {
    int result = 0;
    if (value.isEmpty) {
      throw InvalidIDCode.empty;
    }
    for (final codeUnit in value.reversed) {
      if (codeUnit < idCharMin || codeUnit > idCharMax) {
        throw InvalidIDCode.invalidChar;
      }
      final c = (codeUnit - idCharMin).toUnsigned(64) + 1;
      result *= idCharRange;
      result += c;
    }
    return IDCode.raw(result - 1);
  }

  factory IDCode.fromString(String value) {
    return IDCode(Uint8List.fromList(value.codeUnits));
  }

  /// An arbitrary IdCode with a short representation.
  static final IDCode first = IDCode.fromString('!'); // '0'
  static final idCharMin = 33.toUnsigned(8); // '!'
  static final idCharMax = 126.toUnsigned(8); // '~'
  static final idCharRange = (idCharMax - idCharMin + 1).toUnsigned(64);

  final int value;

  /// Returns the IdCode following this one in an arbitrary sequence.
  IDCode next() => IDCode.raw(value + 1);

  operator <=(IDCode other) => value <= other.value;
  operator >=(IDCode other) => value >= other.value;
  operator <(IDCode other) => value < other.value;
  operator >(IDCode other) => value > other.value;

  @override
  operator ==(Object other) => other is IDCode ? value == other.value : false;

  @override
  String toString() {
    final codeUnits = <int>[];
    int value = this.value;
    do {
      final c = (value % idCharRange) + idCharMin;
      codeUnits.add(c);
      value ~/= idCharRange;
      value -= 1;
    } while (value > -1);

    final str = String.fromCharCodes(codeUnits);
    return str;
  }

  @override
  int get hashCode => Object.hashAll([value]);
}

extension IDCodeParseString on String {
  IDCode parse<T>() => IDCode.fromString(this);
}
