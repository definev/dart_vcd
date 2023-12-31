# dart_vcd

Reads and writes VCD (Value Change Dump) files, a common format used with logic analyzers, HDL simulators, and other EDA tools. It provides streaming wrappers to read and write VCD commands and data.

---
Port of [rust-vcd](https://github.com/kevinmehall/rust-vcd) to Dart.

## Usage

A simple usage example:

```dart
import 'package:dart_vcd/dart_vcd.dart';

void main() {
    VCDWriter writer = StringBufferVCDWriter();
    
    // Write header
    writer.timescale(1, TimescaleUnit.us);
    writer.addModule('top');
    final clock = writer.addWire(1, 'clock');
    final data = writer.addWire(1, 'data');
    writer.upscope();
    writer.enddefinitions();

    // Write values
    writer.begin(SimulationCommand.dumpvars);
    writer.changeScalar(clock, Value.v0);
    writer.changeScalar(data, Value.v0);
    writer.end();

    var t = 0;
    for (var i = 0; i < 32; i++) {
      t += 4;
      writer.timestamp(t);
      writer.changeScalar(clock, Value.v1);
      writer.changeScalar(data, Value.v1);
    }

    print(writer.result);
}
```
