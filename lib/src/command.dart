import 'package:collection/collection.dart';

import 'id_code.dart';
import 'scope_item/scope_item.dart';
import 'scope_item/scope_type.dart';
import 'timescale.dart';
import 'value.dart';
import 'writer.dart';

sealed class Command {
  const Command();

  Command clone();
}

/// A [comment] command
class CommentCommand extends Command {
  const CommentCommand({required this.comment});

  final String comment;

  @override
  Command clone() => CommentCommand(comment: comment);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is CommentCommand && runtimeType == other.runtimeType && comment == other.comment;

  @override
  int get hashCode => comment.hashCode;

  @override
  String toString() => 'CommentCommand(comment: $comment)';
}

/// A [date] command
class DateCommand extends Command {
  const DateCommand({required this.date});

  final String date;

  @override
  Command clone() => DateCommand(date: date);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is DateCommand && runtimeType == other.runtimeType && date == other.date;

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() => 'DateCommand(date: $date)';
}

/// A [version] command
class VersionCommand extends Command {
  const VersionCommand({required this.version});

  final String version;

  @override
  Command clone() => VersionCommand(version: version);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is VersionCommand && runtimeType == other.runtimeType && version == other.version;

  @override
  int get hashCode => version.hashCode;

  @override
  String toString() => 'VersionCommand(version: $version)';
}

/// A [timescale] command
class TimescaleCommand extends Command {
  const TimescaleCommand({required this.ts, required this.unit});

  final int ts;
  final TimescaleUnit unit;

  @override
  Command clone() => TimescaleCommand(ts: ts, unit: unit);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is TimescaleCommand && runtimeType == other.runtimeType && ts == other.ts && unit == other.unit;

  @override
  int get hashCode => Object.hash(ts, unit);

  @override
  String toString() => 'TimescaleCommand(ts: $ts, unit: $unit)';
}

/// A [scope] command
class ScopeDefCommand extends Command {
  const ScopeDefCommand({required this.type, required this.identifier});

  final ScopeType type;
  final String identifier;

  @override
  Command clone() => ScopeDefCommand(type: type, identifier: identifier);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ScopeDefCommand &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          identifier == other.identifier;

  @override
  int get hashCode => Object.hash(type, identifier);

  @override
  String toString() => 'ScopeDefCommand(type: $type, identifier: $identifier)';
}

/// An [upscope] command
class UpscopeCommand extends Command {
  const UpscopeCommand();

  @override
  Command clone() => UpscopeCommand();

  @override
  String toString() => 'UpscopeCommand()';
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

  @override
  Command clone() => VariableDefCommand(type: type, width: width, id: id, reference: reference, index: index);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is VariableDefCommand &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          width == other.width &&
          id == other.id &&
          reference == other.reference &&
          index == other.index;

  @override
  int get hashCode => Object.hash(type, width, id, reference, index);

  @override
  String toString() => 'VariableDefCommand(type: $type, width: $width, id: $id, reference: $reference, index: $index)';
}

/// An [enddefinitions] command
class EnddefinitionsCommand extends Command {
  const EnddefinitionsCommand();

  @override
  Command clone() => EnddefinitionsCommand();

  @override
  String toString() => 'EnddefinitionsCommand()';
}

/// A `#xxx` timestamp
class TimestampCommand extends Command {
  const TimestampCommand({required this.ts});

  final int ts;

  @override
  Command clone() => TimestampCommand(ts: ts);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is TimestampCommand && runtimeType == other.runtimeType && ts == other.ts;

  @override
  int get hashCode => ts.hashCode;

  @override
  String toString() => 'TimestampCommand(ts: $ts)';
}

/// A `0a` change to a scalar variable
class ChangeScalarCommand extends Command {
  const ChangeScalarCommand({required this.id, required this.value});

  final IDCode id;
  final Value value;

  @override
  Command clone() => ChangeScalarCommand(id: id, value: value);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeScalarCommand && runtimeType == other.runtimeType && id == other.id && value == other.value;

  @override
  int get hashCode => Object.hash(id, value);

  @override
  String toString() => 'ChangeScalarCommand(id: $id, value: $value)';
}

/// A `b0000 a` change to a vector variable
class ChangeVectorCommand extends Command {
  const ChangeVectorCommand({required this.id, required this.values});

  final IDCode id;
  final Vector values;

  @override
  Command clone() => ChangeVectorCommand(id: id, values: values);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeVectorCommand && runtimeType == other.runtimeType && id == other.id && IterableEquality().equals(values, other.values);

  @override
  int get hashCode => Object.hash(id, values);

  @override
  String toString() => 'ChangeVectorCommand(id: $id, values: $values)';
}

/// A `r1.234 a` change to a real variable
class ChangeRealCommand extends Command {
  const ChangeRealCommand({required this.id, required this.value});

  final IDCode id;
  final double value;

  @override
  Command clone() => ChangeRealCommand(id: id, value: value);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeRealCommand && runtimeType == other.runtimeType && id == other.id && value == other.value;

  @override
  int get hashCode => Object.hash(id, value);

  @override
  String toString() => 'ChangeRealCommand(id: $id, value: $value)';
}

/// A `sSTART a` change to a string variable
class ChangeStringCommand extends Command {
  const ChangeStringCommand({required this.id, required this.value});

  final IDCode id;
  final String value;

  @override
  Command clone() => ChangeStringCommand(id: id, value: value);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeStringCommand && runtimeType == other.runtimeType && id == other.id && value == other.value;

  @override
  int get hashCode => Object.hash(id, value);

  @override
  String toString() => 'ChangeStringCommand(id: $id, value: $value)';
}

/// A beginning of a simulation command. Unlike header commands, which are parsed atomically,
/// simulation commands emit a Begin, followed by the data changes within them, followed by
/// End.
class BeginCommand extends Command {
  const BeginCommand({required this.command});

  final SimulationCommand command;

  @override
  Command clone() => BeginCommand(command: command);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is BeginCommand && runtimeType == other.runtimeType && command == other.command;

  @override
  int get hashCode => command.hashCode;

  @override
  String toString() => 'BeginCommand(command: $command)';
}

/// An end of a simulation command.
class EndCommand extends Command {
  const EndCommand({required this.command});

  final SimulationCommand command;

  @override
  Command clone() => EndCommand(command: command);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is EndCommand && runtimeType == other.runtimeType && command == other.command;

  @override
  int get hashCode => command.hashCode;

  @override
  String toString() => 'EndCommand(command: $command)';
}
