import 'header.dart';
import 'id_code.dart';
import 'scope_item/scope_item.dart';
import 'writer.dart';

sealed class Command {
  const Command();
}

class Comment extends Command {
  const Comment({required this.comment});

  final String comment;
}

class Date extends Command {
  const Date({required this.data});

  final DateTime data;
}

class Version extends Command {
  const Version({required this.version});

  final String version;
}

class Timescale extends Command {
  const Timescale({required this.ts, required this.unit});

  final int ts;
  final TimescaleUnit unit;
}

class ScopeDef extends Command {
  const ScopeDef({required this.type, required this.i});

  final ScopeType type;
  final String i;
}

class Upscope extends Command {
  const Upscope();
}

class VarDef extends Command {
  const VarDef({
    required this.type,
    required this.width,
    required this.id,
    required this.reference,
    this.inde,
  });

  final VariableType type;
  final int width;
  final IDCode id;
  final String reference;
  final ReferenceIndex? inde;
}

class Enddefinitions extends Command {
  const Enddefinitions();
}

class Timestamp extends Command {
  const Timestamp({required this.ts});

  final int ts;
}

class ChangeScalar extends Command {
  const ChangeScalar({required this.id, required this.value});

  final IDCode id;
  final Value value;
}

class ChangeVector extends Command {
  const ChangeVector({required this.id, required this.values});

  final IDCode id;
  final Iterator<Value> values;
}

class ChangeReal extends Command {
  const ChangeReal({required this.id, required this.value});

  final IDCode id;
  final double value;
}

class ChangeString extends Command {
  const ChangeString({required this.id, required this.value});

  final IDCode id;
  final String value;
}

class Begin extends Command {
  const Begin({required this.command});

  final SimulationCommand command;
}

class End extends Command {
  const End();
}
