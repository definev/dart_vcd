import 'package:dart_vcd/dart_vcd.dart';
import 'package:test/test.dart';

void main() {
  test('id code test', () {
    var id = IDCode.first;
    for (int i = 0; i < 10000; i++) {
      if (i == 94) {
        print('94 ${id.toString()}');
      }
      final currId = IDCode.fromString(id.toString());
      print('$i ${id.toString()}');
      assert(currId == id, 'id code test failed');
      id = id.next();
    }

    assert(IDCode.fromString("!").toString() == "!");
    assert(IDCode.fromString("!!!!!!!!!!").toString() == "!!!!!!!!!!");
    assert(IDCode.fromString("~").toString() == "~");
    assert(IDCode.fromString("~~~~~~~~").toString() == "~~~~~~~~");
  });
}
