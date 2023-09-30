/// A type of scope, as used in the [scope] command.
enum ScopeType {
  module,
  task,
  function,
  begin,
  fork;

  @override
  String toString() => name;
}
