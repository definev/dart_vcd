import 'package:dart_vcd/dart_vcd.dart';
import 'package:dart_vcd/src/parser.dart';
import 'package:test/test.dart';

void main() {
  group('parser test', () {
    test('wikipedia', () {
      final sample = r'''
        $date
        Date text.
        $end
        $version
        VCD generator text.
        $end
        $comment
        Any comment text.
        $end
        $timescale 100 ns $end
        $scope module logic $end
        $var wire 8 # data $end
        $var wire 1 $ data_valid $end
        $var wire 1 % en $end
        $var wire 1 & rx_en $end
        $var wire 1 ' tx_en $end
        $var wire 1 ( empty $end
        $var wire 1 ) underrun $end
        $upscope $end
        $enddefinitions $end
        $dumpvars
        bxxxxxxxx #
        x$
        0%
        x&
        x'
        1(
        0)
        $end
        #0
        b10000001 #
        0$
        1%
        #2211
        0'
        #2296
        b0 #
        1$
        #2302
        0$
        #2303
        ''';
      final parser = StringVCDParser(vcd: sample);
      final header = parser.parseHeader();
      expect(header.date, 'Date text.');
      expect(header.version, 'VCD generator text.');
      expect(header.timescale, (ts: 100, unit: TimescaleUnit.ns));

      expect(header.items[0], Comment(comment: 'Any comment text.'));

      final scope = switch (header.items[1]) {
        Scope() => header.items[1] as Scope,
        _ => throw Exception('Expected Scope'),
      };

      expect(scope.identifier, 'logic');
      expect(scope.type, ScopeType.module);

      final variable = scope.items[0];
      if (variable is Variable) {
        expect(variable.type, VariableType.wire);
        expect(variable.reference, 'data');
        expect(variable.size, 8);
      } else {
        throw Exception('Expected Variable');
      }

      final expected = [
        BeginCommand(command: SimulationCommand.dumpvars),
        ChangeVectorCommand(
          id: IDCode.raw(2),
          values: [Value.x, Value.x, Value.x, Value.x, Value.x, Value.x, Value.x, Value.x],
        ),
        ChangeScalarCommand(id: IDCode.raw(3), value: Value.x),
        ChangeScalarCommand(id: IDCode.raw(4), value: Value.v0),
        ChangeScalarCommand(id: IDCode.raw(5), value: Value.x),
        ChangeScalarCommand(id: IDCode.raw(6), value: Value.x),
        ChangeScalarCommand(id: IDCode.raw(7), value: Value.v1),
        ChangeScalarCommand(id: IDCode.raw(8), value: Value.v0),
        EndCommand(command: SimulationCommand.dumpvars),
        TimestampCommand(ts: 0),
        ChangeVectorCommand(
          id: IDCode.raw(2),
          values: [Value.v1, Value.v0, Value.v0, Value.v0, Value.v0, Value.v0, Value.v0, Value.v1],
        ),
        ChangeScalarCommand(id: IDCode.raw(3), value: Value.v0),
        ChangeScalarCommand(id: IDCode.raw(4), value: Value.v1),
        TimestampCommand(ts: 2211),
        ChangeScalarCommand(id: IDCode.raw(6), value: Value.v0),
        TimestampCommand(ts: 2296),
        ChangeVectorCommand(id: IDCode.raw(2), values: [Value.v0]),
        ChangeScalarCommand(id: IDCode.raw(3), value: Value.v1),
        TimestampCommand(ts: 2302),
        ChangeScalarCommand(id: IDCode.raw(3), value: Value.v0),
        TimestampCommand(ts: 2303),
      ];
      final list = parser.parse();
      expect(list, expected);
    });

    test('name with spaces', () {
      final sample = r'''
$scope module top $end
$var wire 1 ! i_vld [0] $end
$var wire 10 ~ i_data [9:0] $end
$upscope $end
$enddefinitions $end
#0
''';
      final parser = StringVCDParser(vcd: sample);
      final header = parser.parseHeader();

      final scope = switch (header.items[0]) {
        Scope() => header.items[0] as Scope,
        _ => throw Exception('Expected Scope'),
      };

      expect(scope.identifier, 'top');
      expect(scope.type, ScopeType.module);

      final variable = scope.items[0];
      if (variable is Variable) {
        expect(variable.type, VariableType.wire);
        expect(variable.reference, 'i_vld');
        expect(variable.size, 1);
        expect(variable.index, BitSelect(index: 0));
      } else {
        throw Exception('Expected Variable');
      }

      final variable2 = scope.items[1];
      if (variable2 is Variable) {
        expect(variable2.type, VariableType.wire);
        expect(variable2.reference, 'i_data');
        expect(variable2.size, 10);
        expect(variable2.index, Range(msb: 9, lsb: 0));
      } else {
        throw Exception('Expected Variable');
      }
    });
  });
}
