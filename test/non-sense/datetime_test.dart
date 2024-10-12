import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dateTime', () {
    print(DateTime.now());
    print(DateTime.now().millisecond);
    print(DateTime.now().millisecondsSinceEpoch);
    print(DateTime.now().microsecond);
    print(DateTime.now().microsecondsSinceEpoch);
    print(DateTime.fromMillisecondsSinceEpoch(1728656569209));
  });
}
