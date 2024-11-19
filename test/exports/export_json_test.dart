import 'dart:convert';

import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

const json2 = r'''
{
  "id": 1,
  "title": "title",
  "comment": "",
  "dueDate": 1504776600000,
  "priority": 0,
  "status": 1,
  "projectId": 1,
  "order": 0
}
''';

void main() {
  test('output tasks json', () async {
    var task = Task(
      id: 1,
      title: 'title',
      projectId: 1,
      comment: "",
      dueDate: DateTime(2017, 9, 7, 17, 30, 0, 0).millisecondsSinceEpoch,
      priority: PriorityStatus.PRIORITY_1,
      tasksStatus: TaskStatus.COMPLETE,
      order: 0,
    );
    const jsonEncoder = JsonEncoder.withIndent('  ');
    expect(jsonEncoder.convert(task.toMap()), equals(json2.trim()));
  });
}
