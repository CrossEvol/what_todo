import 'dart:convert';

import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('output user json', () {
    var user = User(id: 1, name: 'ce');
    const jsonEncoder = JsonEncoder.withIndent('  ');
    print(jsonEncoder.convert(user.toMap()));
  });

  test('output tasks json', () async {
    var task = Task(
        id: 1,
        title: 'title',
        projectId: 1,
        comment: "",
        dueDate: DateTime.now().second,
        priority: PriorityStatus.PRIORITY_1,
        tasksStatus: TaskStatus.COMPLETE);
    const jsonEncoder = JsonEncoder.withIndent('  ');
    print(jsonEncoder.convert(task.toMap()));
  });
}

class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}
