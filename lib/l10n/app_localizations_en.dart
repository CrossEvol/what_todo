// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get inbox => 'Inbox';

  @override
  String get today => 'Today';

  @override
  String get next7Days => 'Next 7 Days';

  @override
  String get projectGrid => 'Project Grid';

  @override
  String get labelGrid => 'Label Grid';

  @override
  String get settings => 'Settings';

  @override
  String get orderTest => 'OrderTest';

  @override
  String get unknown => 'UNKNOWN';

  @override
  String get unknownNotImplemented => 'Unknown has not implemented.';

  @override
  String get aboutTitle => 'About';

  @override
  String get reportIssueTitle => 'Report an Issue';

  @override
  String get reportIssueSubtitle => 'Having an issue ? Report it here';

  @override
  String get versionTitle => 'Version';

  @override
  String get authorSectionTitle => 'Author';

  @override
  String get authorName => 'Burhanuddin Rashid';

  @override
  String get authorUsername => 'burhanrashid52';

  @override
  String get forkGithub => 'Fork on Github';

  @override
  String get sendEmail => 'Send an Email';

  @override
  String get askQuestion => 'Ask Question ?';

  @override
  String get apacheLicense => 'Apache License';

  @override
  String get licenseText => 'Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the \"License\") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.';

  @override
  String get projects => 'Projects';

  @override
  String get addProject => 'Add Project';

  @override
  String get labels => 'Labels';

  @override
  String get addLabel => 'Add Label';

  @override
  String get failedToLoadProjects => 'Failed to load projects';

  @override
  String get failedToLoadLabels => 'Failed to load labels';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskTitle => 'Title';

  @override
  String get titleCannotBeEmpty => 'Title Cannot be Empty';

  @override
  String get project => 'Project';

  @override
  String get editTask => 'Edit Task';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priority => 'Priority';

  @override
  String get selectPriority => 'Select Priority';

  @override
  String get selectProject => 'Select Project';

  @override
  String get selectLabels => 'Select Labels';

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No Comments';

  @override
  String get reminder => 'Reminder';

  @override
  String get noReminder => 'No Reminder';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get noLabels => 'No Labels';

  @override
  String get labelName => 'Label Name';

  @override
  String get labelCannotBeEmpty => 'Label Cannot be empty';

  @override
  String get labelAlreadyExists => 'Label already exists';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectNameCannotBeEmpty => 'Project name cannot be empty';

  @override
  String get projectAlreadyExists => 'Project already exists';

  @override
  String get completedTasks => 'Completed Tasks';

  @override
  String get uncompletedTasks => 'Uncompleted Tasks';

  @override
  String get allToToday => 'All to Today';

  @override
  String get postponeTasks => 'Postpone Tasks';

  @override
  String get exports => 'Exports';

  @override
  String get imports => 'Imports';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get avatarUrl => 'Avatar URL';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get importFile => 'Import File';

  @override
  String get filePath => 'File Path';

  @override
  String get pickFile => 'Pick File';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get importError => 'Import error';

  @override
  String get chooseExportFormat => 'Choose export format';

  @override
  String get legacyFormat => 'Legacy Format';

  @override
  String get newFormat => 'New Format';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportError => 'Export error';

  @override
  String get noTaskAdded => 'No Task Added';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get fieldCannotBeEmpty => 'Field must not be empty';

  @override
  String valueTooLong(int maxLength) {
    return 'Value cannot be longer than $maxLength characters';
  }
}
