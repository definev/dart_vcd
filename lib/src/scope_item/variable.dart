part of 'scope_item.dart';

enum VariableType {
  event,
  interger,
  parameter,
  real,
  reg,
  supply0,
  supply1,
  time,
  tri,
  triAnd,
  triOr,
  triReg,
  tri0,
  tri1,
  wAnd,
  wire,
  wOr,
  string
}

sealed class ReferenceIndex {
  const ReferenceIndex();
}

class BitSelect extends ReferenceIndex {
  const BitSelect({required this.index});

  final int index;
}

class Range extends ReferenceIndex {
  const Range({required this.from, required this.to});

  final int from;
  final int to;
}

class Variable extends ScopeItem {
  const Variable(
      {required this.type, required this.size, required this.code, required this.reference, required this.index});

  final VariableType type;
  final int size;
  final IDCode code;
  final String reference;
  final ReferenceIndex? index;
}
