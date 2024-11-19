import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAdminBloc extends MockBloc<AdminEvent, AdminState>
    implements AdminBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockLabelBloc extends MockBloc<LabelEvent, LabelState>
    implements LabelBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockProjectBloc extends MockBloc<ProjectEvent, ProjectState>
    implements ProjectBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

void main() {
  test('create mock BLOCs', () {
    var adminBloc = MockAdminBloc();
    var homeBloc = MockHomeBloc();
    var labelBloc = MockLabelBloc();
    var profileBloc = MockProfileBloc();
    var projectBloc = MockProjectBloc();
    var settingsBloc = MockSettingsBloc();
    var taskBloc = MockTaskBloc();
  });
}
