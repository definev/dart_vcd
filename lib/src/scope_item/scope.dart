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
}
