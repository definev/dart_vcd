part of 'scope_item.dart';

/// [scope] - Child scope
///
/// Information on a VCD scope as represented by a [scope] command and its children.
class Scope extends ScopeItem {
  /// Create a [Scope].
  const Scope({required this.type, required this.identifier, required this.items});

  /// Type of scope.
  final ScopeType type;

  /// Name of the scope.
  final String identifier;

  /// Items within the scope.
  final List<ScopeItem> items;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scope && other.type == type && other.identifier == identifier && other.items == items;
  }

  @override
  int get hashCode => Object.hash(type, identifier, items);
}
