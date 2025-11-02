import 'package:flutter_app/dao/reminder_db.dart' show ReminderDB;
import 'package:flutter_app/dao/resource_db.dart';
import 'package:flutter_app/dao/search_db.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
import 'fake-database.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LabelDB>(),
  MockSpec<ReminderDB>(),
  MockSpec<ProjectDB>(),
  MockSpec<ProfileDB>(),
  MockSpec<SettingsDB>(),
  MockSpec<TaskDB>(),
  MockSpec<SearchDB>(),
  MockSpec<ResourceDB>(),
])
void main() {
  test('create mock DAOs', () {
    var labelDB = MockLabelDB();
    var reminderDB = MockReminderDB();
    var projectDB = MockProfileDB();
    var profileDB = MockProfileDB();
    var settingsDB = MockSettingsDB();
    var taskDB = MockTaskDB();
    var searchDB = MockSearchDB();
    var resourceDB = MockResourceDB();
  });
}
