part of 'scope_item.dart';

class Scope extends ScopeItem {
  const Scope({required this.type, required this.identifier, required this.items});

  final ScopeType type;
  final String identifier;
  final List<ScopeItem> items;
}
