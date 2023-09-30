import 'scope_item/scope_item.dart';

enum TimescaleUnit { s, ms, us, ns, ps, fs }

typedef Timescale = (int ts, TimescaleUnit unit);

class Header {
  const Header({required this.data, required this.version, required this.timescale, required this.items});

  final DateTime data;
  final String version;
  final Timescale timescale;
  final List<ScopeItem> items;
}
