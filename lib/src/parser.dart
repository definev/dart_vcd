import 'package:dart_vcd/dart_vcd.dart';

class VCDParserError {
  const VCDParserError({required this.line, required this.kind});

  final int line;
  final VCDParseErrorKind kind;

  @override
  String toString() => 'VCDParserError: $kind at line $line';
}

enum VCDParseErrorKind {
  invalidUtf8,
  unexpectedCharacter,
  unexpectedEof,
  tokenTooLong,
  expectedEndCommand,
  unmatchedEnd,
  unknownCommand,
  unexpectedHeaderCommand,
  parseIntError,
  parseFloatError,
  invalidTimescaleUnit,
  invalidScopeType,
  invalidVarType,
  invalidReferenceIndex,
  invalidValueChar,
  invalidIdCode;

  @override
  String toString() => switch (this) {
        invalidUtf8 => 'invalid UTF-8',
        unexpectedCharacter => 'unexpected character at start of command',
        unexpectedEof => 'unexpected end of file',
        tokenTooLong => 'token too long',
        expectedEndCommand => 'expected \'\$end\' command',
        unmatchedEnd => 'unmatched \'\$end\' command',
        unknownCommand => 'unknown command',
        unexpectedHeaderCommand => 'unexpected command in header',
        parseIntError => 'invalid integer',
        parseFloatError => 'invalid floating point number',
        invalidTimescaleUnit => 'invalid timescale unit',
        invalidScopeType => 'invalid scope type',
        invalidVarType => 'invalid variable type',
        invalidReferenceIndex => 'invalid reference index',
        invalidValueChar => 'invalid value character',
        invalidIdCode => 'invalid ID code',
      };
}

bool whitespace(String b) => b == ' ' || b == '\t' || b == '\n' || b == '\r';

/// VCD parser.
abstract class VCDParser implements Iterator<Command?> {
  VCDParser({
    this.line = 1,
    this.endOfLine = false,
    this.simulationCommand,
  });

  int line;
  bool endOfLine;
  SimulationCommand? simulationCommand;

  String? readByteOrEOF();

  String readByte() {
    return switch (readByteOrEOF()) {
      null => throw VCDParserError(line: line, kind: VCDParseErrorKind.unexpectedCharacter),
      final current => current,
    };
  }

  Command? _current;
  @override
  Command? get current => _current;
  @override
  bool moveNext() {
    final b = readByteOrEOF();
    if (b == null) return false;
    return switch (b) {
      ' ' || '\t' || '\n' || '\r' => () {
          _current = null;
          return true;
        }(),
      '\$' => () {
          _current = parseCommand();
          return true;
        }(),
      '#' => () {
          _current = parseTimestamp();
          return true;
        }(),
      '0' || '1' || 'z' || 'Z' || 'x' || 'X' => () {
          _current = parseScalar(b);
          return true;
        }(),
      'b' || 'B' => () {
          _current = parseVector();
          return true;
        }(),
      'r' || 'R' => () {
          _current = parseReal();
          return true;
        }(),
      's' || 'S' => () {
          _current = parseString();
          return true;
        }(),
      _ => () {
          throw VCDParserError(line: line, kind: VCDParseErrorKind.unexpectedCharacter);
        }(),
    };
  }

  List<Command> parse() {
    final commands = List<Command>.empty(growable: true);
    while (moveNext()) {
      if (current case final current?) {
        commands.add(current.clone());
      }
    }
    return commands;
  }

  String readToken() {
    int len = 0;
    String tok = '';
    while (true) {
      String b = readByte();
      if (whitespace(b)) {
        if (len > 0) {
          break;
        } else {
          continue;
        }
      }

      try {
        tok += b;
      } catch (e) {
        throw VCDParserError(line: line, kind: VCDParseErrorKind.tokenTooLong);
      }

      len++;
    }
    return tok;
  }

  void readCommandEnd() {
    final tok = readToken();
    if (tok != '\$end') {
      throw VCDParserError(line: line, kind: VCDParseErrorKind.expectedEndCommand);
    }
  }

  String readStringCommand() {
    String r = '';
    while (true) {
      r += readByte();
      if (r.endsWith('\$end')) {
        break;
      }
    }

    return r.substring(0, r.length - 4).trim();
  }

  Command parseCommand() {
    final cmd = readToken();
    return switch (cmd) {
      'comment' => CommentCommand(comment: readStringCommand()),
      'date' => DateCommand(date: readStringCommand()),
      'version' => VersionCommand(version: readStringCommand()),
      'timescale' => () {
          final quantity = readToken();
          final unit = readToken();
          readCommandEnd();
          return TimescaleCommand(ts: int.parse(quantity), unit: TimescaleUnit.values.asNameMap()[unit]!);
        }(),
      'scope' => () {
          final scopeType = ScopeType.values.asNameMap()[readToken()]!;
          final identifier = readToken();
          readCommandEnd();
          return ScopeDefCommand(type: scopeType, identifier: identifier);
        }(),
      'upscope' => () {
          readCommandEnd();
          return UpscopeCommand();
        }(),
      'var' => () {
          final varType = VariableType.values.asNameMap()[readToken()]!;
          final size = int.parse(readToken());
          final id = IDCode.fromString(readToken());
          final reference = readToken();

          var tok = readToken();
          final index = () {
            if (tok.startsWith('[')) {
              final value = ReferenceIndex.fromString(tok);
              tok = readToken();
              return value;
            }
            return null;
          }();
          if (tok != '\$end') {
            throw VCDParserError(line: line, kind: VCDParseErrorKind.expectedEndCommand);
          }
          return VariableDefCommand(
            type: varType,
            width: size,
            id: id,
            reference: reference,
            index: index,
          );
        }(),
      'enddefinitions' => () {
          readCommandEnd();
          return EnddefinitionsCommand();
        }(),
      'dumpall' => beginSimulationCommand(SimulationCommand.dumpall),
      'dumpoff' => beginSimulationCommand(SimulationCommand.dumpoff),
      'dumpon' => beginSimulationCommand(SimulationCommand.dumpon),
      'dumpvars' => beginSimulationCommand(SimulationCommand.dumpvars),
      'end' => () {
          if (simulationCommand == null) {
            throw VCDParserError(line: line, kind: VCDParseErrorKind.unmatchedEnd);
          }
          return EndCommand(command: simulationCommand!);
        }(),
      _ => throw VCDParserError(line: line, kind: VCDParseErrorKind.unknownCommand),
    };
  }

  Command beginSimulationCommand(SimulationCommand command) {
    simulationCommand = command;
    return BeginCommand(command: command);
  }

  Command parseTimestamp() {
    return TimestampCommand(ts: int.parse(readToken()));
  }

  Command parseScalar(String scalar) {
    final id = IDCode.fromString(readToken());
    final value = Value.fromString(scalar);
    return ChangeScalarCommand(id: id, value: value);
  }

  Command parseVector() {
    List<Value> values = [];
    while (true) {
      final b = readByte();
      if (whitespace(b)) {
        if (values.isEmpty) {
          continue;
        } else {
          break;
        }
      }
      values.add(Value.fromString(b));
    }
    final id = IDCode.fromString(readToken());
    return ChangeVectorCommand(id: id, values: values);
  }

  Command parseReal() {
    final value = double.parse(readToken());
    final id = IDCode.fromString(readToken());
    return ChangeRealCommand(id: id, value: value);
  }

  Command parseString() {
    final value = readToken();
    final id = IDCode.fromString(readToken());
    return ChangeStringCommand(id: id, value: value);
  }

  Scope parseScope(
    ScopeType type,
    String identifier,
  ) {
    final children = List<ScopeItem>.empty(growable: true);
    loop: while (moveNext()) {
      final cmd = current;
      switch (cmd) {
        case null:
          continue;
        case UpscopeCommand():
          break loop;
        case ScopeDefCommand(:final type, :final identifier):
          children.add(parseScope(type, identifier));
        case VariableDefCommand(
            :final id,
            :final reference,
            :final type,
            :final width,
            :final index,
          ):
          children.add(
            Variable(
              type: type,
              size: width,
              id: id,
              reference: reference,
              index: index,
            ),
          );
        case CommentCommand(:final comment):
          children.add(Comment(comment: comment));
        default:
          throw VCDParserError(line: line, kind: VCDParseErrorKind.unexpectedHeaderCommand);
      }
    }
    return Scope(type: type, identifier: identifier, items: children);
  }

  Header parseHeader() {
    var header = Header.defaultValue();
    loop: while (moveNext()) {
      final cmd = current;
      switch (cmd) {
        case null:
          continue;
        case EnddefinitionsCommand():
          break loop;
        case CommentCommand(:final comment):
          header.items.add(Comment(comment: comment));
        case DateCommand(:final date):
          header = header.copyWith(date: date);
        case VersionCommand(:final version):
          header = header.copyWith(version: version);
        case TimescaleCommand(:final ts, :final unit):
          header = header.copyWith(timescale: (ts: ts, unit: unit));
        case ScopeDefCommand(:final type, :final identifier):
          header.items.add(parseScope(type, identifier));
        case VariableDefCommand(
            :final id,
            :final reference,
            :final type,
            :final width,
            :final index,
          ):
          header.items.add(
            Variable(
              type: type,
              size: width,
              id: id,
              reference: reference,
              index: index,
            ),
          );
        default:
          throw VCDParserError(line: line, kind: VCDParseErrorKind.unexpectedHeaderCommand);
      }
    }
    return header;
  }
}

class StringVCDParser extends VCDParser {
  int at = 0;
  final String _vcd;

  StringVCDParser({
    super.line,
    super.endOfLine,
    super.simulationCommand,
    required String vcd,
  }) : _vcd = vcd;

  @override
  String? readByteOrEOF() {
    if (at >= _vcd.length) return null;

    final b = _vcd[at++];

    if (endOfLine) line++;
    endOfLine = b == '\n';

    return b;
  }
}
