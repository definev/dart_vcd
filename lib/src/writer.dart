import 'package:dart_vcd/src/command.dart';

import 'header.dart';
import 'id_code.dart';
import 'scope_item/scope_item.dart';
import 'scope_item/scope_type.dart';
import 'timescale.dart';
import 'value.dart';

/// A simulation command type, used in [Begin] and [End].
enum SimulationCommand {
  dumpall,
  dumpoff,
  dumpon,
  dumpvars;

  @override
  String toString() => name;
}

/// VCDWriter is a class that writes VCD file.
abstract class VCDWriter {
  VCDWriter({required this.nextIDCode, this.scopeDepth = 0});

  IDCode nextIDCode;
  int scopeDepth;

  void write(String s);

  void writeln(String s) => write('$s\n');

  String get result;

  /// Flush the data.
  void flush();

  /// Writes a complete header with the fields from a [Header] struct from the parser.
  void header(Header header) {
    final Header(:date, :items, :timescale, :version) = header;
    if (date != null) this.date(date);
    if (version != null) this.version(version);
    if (timescale != null) this.timescale(timescale.ts, timescale.unit);

    for (final i in items) {
      final _ = switch (i) {
        Variable() => variable(i),
        Scope() => scope(i),
        Comment(comment: final c) => comment(c),
      };
    }

    enddefinitions();
  }

  /// Writes a [comment] command.
  void comment(String comment) {
    writeln("\$comment\n    $comment\n\$end");
  }

  /// Writes a [date] command.
  void date(String date) {
    writeln("\$date\n    $date\n\$end");
  }

  /// Writes a [version] command.
  void version(String version) {
    writeln("\$version\n    $version\n\$end");
  }

  /// Writes a [timescale] command.
  void timescale(int ts, TimescaleUnit unit) {
    writeln("\$timescale $ts $unit \$end");
  }

  /// Writes a [scope] command.
  void scopeDef(ScopeType type, String i) {
    scopeDepth++;
    writeln("\$scope $type $i \$end");
  }

  /// Writes a [scope] command for a module.
  void addModule(String identifier) {
    scopeDef(ScopeType.module, identifier);
  }

  /// Writes an [upscope] command.
  void upscope() {
    assert(
      scopeDepth > 0,
      "Generate invalid VCD: upscope without a matching scope",
    );
    scopeDepth--;
    writeln("\$upscope \$end");
  }

  /// Writes a [scope] command, a series of [variable] commands, and an
  /// [upscope] commands from a [Scope] structure from the parser.
  void scope(Scope scope) {
    scopeDef(scope.type, scope.identifier);
    for (final item in scope.items) {
      final _ = switch (item) {
        Variable() => variable(item),
        Scope() => this.scope(item),
        Comment(comment: final c) => comment(c),
      };
    }
    upscope();
  }

  /// Writes a [variable] command with a specified id.
  void variableDef({
    required VariableType type,
    required int width,
    required IDCode id,
    required String reference,
    ReferenceIndex? index,
  }) {
    assert(
      scopeDepth > 0,
      "Generate invalid VCD: variable must be in a scope",
    );
    if (id >= nextIDCode) {
      nextIDCode = id.next();
    }
    final _ = switch (index) {
      null => writeln("\$var $type $width $id $reference \$end"),
      final index => writeln("\$var $type $width $id $reference $index \$end"),
    };
  }

  /// Writes a [variable] command with the next available ID, returning the assigned ID.
  IDCode addVariable({
    required VariableType type,
    required int width,
    required String reference,
    ReferenceIndex? index,
  }) {
    final id = nextIDCode;
    variableDef(type: type, width: width, id: id, reference: reference, index: index);
    return id;
  }

  /// Adds a [variable] for a wire with the next available ID, returning the assigned ID.
  IDCode addWire(int width, String reference) {
    return addVariable(type: VariableType.wire, width: width, reference: reference, index: null);
  }

  /// Writes a [variable] command from a [Variable] structure from the parser.
  void variable(Variable variable) {
    variableDef(
      type: variable.type,
      width: variable.size,
      id: variable.id,
      reference: variable.reference,
      index: variable.index,
    );
  }

  /// Writes a [enddefinitions] command to end the header.
  void enddefinitions() {
    assert(
      scopeDepth == 0,
      "Generate invalid VCD: 0 scopes must be closed with upscope before enddefinitions",
    );
    writeln("\$enddefinitions \$end");
  }

  /// Writes a `#xxx` timestamp.
  void timestamp(int ts) {
    writeln("#$ts");
  }

  /// Writes a change to a scalar variable.
  void changeScalar(IDCode id, Value value) {
    writeln("$value$id");
  }

  /// Writes a change to a vector variable.
  void changeVector(IDCode id, Vector values) {
    writeln("b");
    for (final v in values) {
      write(v.toString());
    }
    writeln(" $id");
  }

  /// Writes a change to a real variable.
  void changeReal(IDCode id, double value) {
    writeln("r$value $id");
  }

  /// Writes a change to a string variable.
  void changeString(IDCode id, String value) {
    writeln("s$value $id");
  }

  /// Writes the beginning of a simulation command.
  void begin(SimulationCommand command) {
    writeln("\$$command");
  }

  /// Writes an [end] to end a simulation command.
  void end() {
    writeln("\$end");
  }

  /// Writes a command from a [Command] enum as parsed by the parser.
  void command(Command command) => switch (command) {
        CommentCommand(:final comment) => this.comment(comment),
        DateCommand(:final date) => this.date(date),
        VersionCommand(:final version) => this.version(version),
        TimescaleCommand(:final ts, :final unit) => timescale(ts, unit),
        ScopeDefCommand(:final type, identifier: final i) => scopeDef(type, i),
        UpscopeCommand() => upscope(),
        VariableDefCommand(
          :final type,
          :final width,
          :final id,
          :final reference,
          :final index,
        ) =>
          variableDef(
            type: type,
            width: width,
            id: id,
            reference: reference,
            index: index,
          ),
        EnddefinitionsCommand() => enddefinitions(),
        TimestampCommand(:final ts) => timestamp(ts),
        ChangeScalarCommand(:final id, :final value) => changeScalar(id, value),
        ChangeVectorCommand(:final id, :final values) => changeVector(id, values),
        ChangeRealCommand(:final id, :final value) => changeReal(id, value),
        ChangeStringCommand(:final id, :final value) => changeString(id, value),
        BeginCommand(:final command) => begin(command),
        EndCommand() => end(),
      };
}

class StringBufferVCDWriter extends VCDWriter {
  StringBufferVCDWriter({IDCode? nextIDCode, int? scopeDepth})
      : super(nextIDCode: nextIDCode ?? IDCode.first, scopeDepth: scopeDepth ?? 0);

  final StringBuffer _buffer = StringBuffer();

  @override
  void write(String s) => _buffer.write(s);

  @override
  void flush() => _buffer.clear();

  @override
  String get result => _buffer.toString();
}
