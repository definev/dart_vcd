import 'package:dart_vcd/src/id_code.dart';

part 'comment.dart';
part 'scope.dart';
part 'variable.dart';

enum ScopeType { module, task, function, begin, fork }

sealed class ScopeItem {
  const ScopeItem();
}
