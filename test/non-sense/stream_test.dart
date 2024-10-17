import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stream', () {
    void main() {
      List<String> fruits = ["apple", "banana", "cherry", "date"];

      // Create a new sorted list
      List<String> sortedFruits = List.from(fruits)..sort();

      print(sortedFruits); // Output: ["apple", "banana", "cherry", "date"]
    }
  });
}
