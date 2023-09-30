import 'id_code.dart';
import 'scope_item/scope_item.dart';
import 'scope_item/scope_type.dart';
import 'timescale.dart';
import 'value.dart';
import 'writer.dart';

sealed class Command {
  const Command();
}

/// A [comment] command
class CommentCommand extends Command {
  const CommentCommand({required this.comment});

  final String comment;
}

/// A [date] command
class DateCommand extends Command {
  const DateCommand({required this.date});

  final String date;
}

/// A [version] command
class VersionCommand extends Command {
  const VersionCommand({required this.version});

  final String version;
}

/// A [timescale] command
class TimescaleCommand extends Command {
  const TimescaleCommand({required this.ts, required this.unit});

  final int ts;
  final TimescaleUnit unit;
}

/// A [scope] command
class ScopeDefCommand extends Command {
  const ScopeDefCommand({required this.type, required this.i});

  final ScopeType type;
  final String i;
}

/// An [upscope] command
class UpscopeCommand extends Command {
  const UpscopeCommand();
}

/// A [variable] command
class VariableDefCommand extends Command {
  const VariableDefCommand({
    required this.type,
    required this.width,
    required this.id,
    required this.reference,
    this.index,
  });

  final VariableType type;
  final int width;
  final IDCode id;
  final String reference;
  final ReferenceIndex? index;
}

/// An [enddefinitions] command
class EnddefinitionsCommand extends Command {
  const EnddefinitionsCommand();
}

/// A `#xxx` timestamp
class TimestampCommand extends Command {
  const TimestampCommand({required this.ts});

  final int ts;
}

/// A `0a` change to a scalar variable
class ChangeScalarCommand extends Command {
  const ChangeScalarCommand({required this.id, required this.value});

  final IDCode id;
  final Value value;
}

/// A `b0000 a` change to a vector variable
class ChangeVectorCommand extends Command {
  const ChangeVectorCommand({required this.id, required this.values});

  final IDCode id;
  final Vector values;
}

/// A `r1.234 a` change to a real variable
class ChangeRealCommand extends Command {
  const ChangeRealCommand({required this.id, required this.value});

  final IDCode id;
  final double value;
}

/// A `sSTART a` change to a string variable
class ChangeStringCommand extends Command {
  const ChangeStringCommand({required this.id, required this.value});

  final IDCode id;
  final String value;
}

/// A beginning of a simulation command. Unlike header commands, which are parsed atomically,
/// simulation commands emit a Begin, followed by the data changes within them, followed by
/// End.
class BeginCommand extends Command {
  const BeginCommand({required this.command});

  final SimulationCommand command;
}

/// An end of a simulation command.
class EndCommand extends Command {
  const EndCommand({required this.command});

  final SimulationCommand command;
}
