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
  String get licenseText =>
      'Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the \"License\") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.';

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
  String get done => 'done';

  @override
  String get undone => 'undone';

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
  String get export => 'Export';

  @override
  String get tasks => 'Tasks';

  @override
  String get delete => 'DELETE';

  @override
  String get removeProject => 'Remove Project';

  @override
  String get removeLabel => 'Remove Label';

  @override
  String get chooseOption => 'Choose an option:';

  @override
  String get removeRelatedTasks => 'Remove related tasks';

  @override
  String get onlyRemoveProject => 'Only remove project';

  @override
  String get onlyRemoveLabel => 'Only remove label';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get legacyFormatV0 => 'Legacy Format (v0)';

  @override
  String get newFormatV1 => 'New Format (v1)';

  @override
  String exportSuccess(String path) {
    return 'Export Success: $path';
  }

  @override
  String exportError(String error) {
    return 'Export Error: $error';
  }

  @override
  String get storagePermissionRequired => 'Storage permissions required';

  @override
  String get count => 'Count';

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

  @override
  String get import => 'Import';

  @override
  String get importDescription =>
      'Import your tasks from a JSON file exported previously.';

  @override
  String get importing => 'Importing...';

  @override
  String get importInformation => 'Import Information';

  @override
  String get importInfoLegacySupport =>
      '• Supports both v0 (legacy) and v1 (new) format';

  @override
  String get importInfoAutoDetect =>
      '• Import will automatically detect the format';

  @override
  String get importInfoTasksAdded =>
      '• All imported tasks will be added to your task list';

  @override
  String get importInfoItemsCreated =>
      '• Projects and labels will be created as needed';

  @override
  String get importingData => 'Importing data...';

  @override
  String get importingWait => 'Please wait while your data is being imported.';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get cannotReadFile => 'Cannot read file';

  @override
  String get invalidJsonFormat => 'Invalid JSON format';

  @override
  String get goBack => 'Go Back';

  @override
  String get controls => 'Controls';

  @override
  String get taskGrid => 'Task Grid';

  @override
  String get manageResources => 'Manage Resources';

  @override
  String get retry => 'Retry';

  @override
  String get noResourcesAttached => 'No resources attached';

  @override
  String get tapAddToAttachImages => 'Tap the + button to attach images';

  @override
  String get addResource => 'Add Resource';

  @override
  String get resourceDeleted => 'Resource deleted';

  @override
  String get viewFullSize => 'View full size';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteResourceConfirmation =>
      'Are you sure you want to delete this resource? This action cannot be undone.';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';
}
