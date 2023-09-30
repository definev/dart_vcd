/// A unit of time for the [timescale] command.
enum TimescaleUnit {
  /// Second
  s,

  /// Millisecond (10^-3)
  ms,

  /// Microsecond (10^-6)
  us,

  /// Nanosecond (10^-9)
  ns,

  /// Picosecond (10^-12)
  ps,

  /// Femtosecond (10^-15)
  fs;

  /// The number of timescale ticks per second.
  int divisor() => switch (this) {
        s => 1,
        ms => 1000,
        us => 1000000,
        ns => 1000000000,
        ps => 1000000000000,
        fs => 1000000000000000,
      };

  /// The duration of a timescale tick in seconds.
  double fraction() => 1.0 / divisor();
}

typedef Timescale = ({int ts, TimescaleUnit unit});
