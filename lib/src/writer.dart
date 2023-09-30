import 'package:dart_vcd/src/command.dart';

import 'header.dart';
import 'id_code.dart';
import 'scope_item/scope_item.dart';

enum Value {
  /// Logic low
  ///
  /// Value: 0
  v0,

  /// Logic high
  ///
  /// Value: 1
  v1,

  /// An uninitialized or unknown value
  x,

  /// The "high-impedance" state
  z,
}

enum SimulationCommand {
  dumpall,
  dumpoff,
  duppon,
  dumpvars,
}

/// VCDWriter is a class that writes VCD file.
abstract class VCDWriter {
  const VCDWriter({this.idCode = IDCode.first, this.scopeDepth = 0});

  final IDCode idCode;
  final int scopeDepth;

  void flush();
  void header(Header header);
  void comment(String comment);
  void date(DateTime date);
  void version(String version);
  void timescale(int ts, TimescaleUnit unit);
  void scopeDef(ScopeType type, String i);
  void addModule(String identifier);
  void upscope();
  void scope(Scope scope);
  void variableDef({
    required VariableType type,
    required int width,
    required IDCode id,
    required String reference,
    ReferenceIndex? index,
  });
  void addWire(int width, String reference);
  void variable(Variable variable);
  void enddefinitions();
  void timestamp(int ts);
  void changeScalar(IDCode id, Value value);
  void changeVector(IDCode id, Iterator<Value> values);
  void changeReal(IDCode id, double value);
  void changeString(IDCode id, String value);
  void begin(SimulationCommand command);
  void end();
  void command(Command command);
}
