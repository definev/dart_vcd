/// A four-valued logic scalar value.
enum Value {
  /// Logic low
  ///
  /// Value: 0
  v0,

  /// Logic high
  ///
  /// Value: 1
  v1,

  /// An uninitialized or unknown value
  x,

  /// The "high-impedance" state
  z;

  factory Value.fromString(String v) => switch (v) {
        '0' => Value.v0,
        '1' => Value.v1,
        'x' || 'X' => Value.x,
        'z' || 'Z' => Value.z,
        _ => throw FormatException('Invalid value: $v'),
      };

  factory Value.fromBool(bool v) => v ? Value.v1 : Value.v0;

  @override
  String toString() => switch (this) {
        Value.v0 => '0',
        Value.v1 => '1',
        Value.x => 'x',
        Value.z => 'z',
      };
}

typedef Vector = List<Value>;
