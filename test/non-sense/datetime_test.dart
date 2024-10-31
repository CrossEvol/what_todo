import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dateTime', () {
    print(DateTime.now());
    print(DateTime.now().millisecond);
    print(DateTime.now().millisecondsSinceEpoch);
    print(DateTime.now().microsecond);
    print(DateTime.now().microsecondsSinceEpoch);
    print(DateTime.fromMillisecondsSinceEpoch(1728656569209));
    var now = DateTime.now();
    print(DateTime(now.year, now.month, now.day));
    print(DateTime(now.year, now.month, now.day, 23, 59));
    print(DateTime(now.year, now.month, now.day, 23, 59).millisecondsSinceEpoch);
    print(DateTime(now.year, now.month, now.day + 1));
    print('---------------------------------->');
    print(now.toString()); // 2024-10-30 22:26:06.223657
    print(now.toIso8601String()); // 2024-10-30T22:26:06.223657
    print(now.toLocal().toString()); // 2024-10-30 22:26:06.223657




  });
}
