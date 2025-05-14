import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// Title for the inbox menu item
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// Title for the today menu item
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Title for the next 7 days menu item
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get next7Days;

  /// Title for the project grid view
  ///
  /// In en, this message translates to:
  /// **'Project Grid'**
  String get projectGrid;

  /// Title for the label grid view
  ///
  /// In en, this message translates to:
  /// **'Label Grid'**
  String get labelGrid;

  /// Title for the settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Title for the order test menu item (only shown in test environment)
  ///
  /// In en, this message translates to:
  /// **'OrderTest'**
  String get orderTest;

  /// Title for the unknown menu item
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get unknown;

  /// Message shown when unknown feature is clicked
  ///
  /// In en, this message translates to:
  /// **'Unknown has not implemented.'**
  String get unknownNotImplemented;

  /// Title for the about screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Title for report issue section
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssueTitle;

  /// Subtitle for report issue section
  ///
  /// In en, this message translates to:
  /// **'Having an issue ? Report it here'**
  String get reportIssueSubtitle;

  /// Title for version section
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// Title for author section
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorSectionTitle;

  /// Name of the author
  ///
  /// In en, this message translates to:
  /// **'Burhanuddin Rashid'**
  String get authorName;

  /// Username of the author
  ///
  /// In en, this message translates to:
  /// **'burhanrashid52'**
  String get authorUsername;

  /// Text for Github fork button
  ///
  /// In en, this message translates to:
  /// **'Fork on Github'**
  String get forkGithub;

  /// Text for email button
  ///
  /// In en, this message translates to:
  /// **'Send an Email'**
  String get sendEmail;

  /// Title for social media section
  ///
  /// In en, this message translates to:
  /// **'Ask Question ?'**
  String get askQuestion;

  /// Title for license section
  ///
  /// In en, this message translates to:
  /// **'Apache License'**
  String get apacheLicense;

  /// Full license text
  ///
  /// In en, this message translates to:
  /// **'Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the \"License\") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.'**
  String get licenseText;

  /// Title for the projects section
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// Text for add project button
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// Title for the labels section
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labels;

  /// Text for add label button
  ///
  /// In en, this message translates to:
  /// **'Add Label'**
  String get addLabel;

  /// Error message when projects fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects'**
  String get failedToLoadProjects;

  /// Error message when labels fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load labels'**
  String get failedToLoadLabels;

  /// Title for add task screen
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Label for task title input field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitle;

  /// Validation message for empty task title
  ///
  /// In en, this message translates to:
  /// **'Title Cannot be Empty'**
  String get titleCannotBeEmpty;

  /// Label for project selection
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// Title for edit task screen
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Label for due date selection
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label for priority selection
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Title for priority selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get selectPriority;

  /// Title for project selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Project'**
  String get selectProject;

  /// Title for labels selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Labels'**
  String get selectLabels;

  /// Label for comments section
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Text shown when no comments exist
  ///
  /// In en, this message translates to:
  /// **'No Comments'**
  String get noComments;

  /// Label for reminder section
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// Text shown when no reminder is set
  ///
  /// In en, this message translates to:
  /// **'No Reminder'**
  String get noReminder;

  /// Text shown for features that are not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Text shown when no labels are selected
  ///
  /// In en, this message translates to:
  /// **'No Labels'**
  String get noLabels;

  /// Label for label name input field
  ///
  /// In en, this message translates to:
  /// **'Label Name'**
  String get labelName;

  /// Validation message for empty label name
  ///
  /// In en, this message translates to:
  /// **'Label Cannot be empty'**
  String get labelCannotBeEmpty;

  /// Error message when creating duplicate label
  ///
  /// In en, this message translates to:
  /// **'Label already exists'**
  String get labelAlreadyExists;

  /// Label for project name input field
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// Validation message for empty project name
  ///
  /// In en, this message translates to:
  /// **'Project name cannot be empty'**
  String get projectNameCannotBeEmpty;

  /// Error message when creating duplicate project
  ///
  /// In en, this message translates to:
  /// **'Project already exists'**
  String get projectAlreadyExists;

  /// Text for completed tasks menu item
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// Text for uncompleted tasks menu item
  ///
  /// In en, this message translates to:
  /// **'Uncompleted Tasks'**
  String get uncompletedTasks;

  /// task has the completed status
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get done;

  /// task has the pending status
  ///
  /// In en, this message translates to:
  /// **'undone'**
  String get undone;

  /// Text for moving all tasks to today menu item
  ///
  /// In en, this message translates to:
  /// **'All to Today'**
  String get allToToday;

  /// Text for postpone tasks menu item
  ///
  /// In en, this message translates to:
  /// **'Postpone Tasks'**
  String get postponeTasks;

  /// Text for exports menu item
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get exports;

  /// Text for imports menu item
  ///
  /// In en, this message translates to:
  /// **'Imports'**
  String get imports;

  /// Title for the profile page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for name input field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for avatar URL input field
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get avatarUrl;

  /// Text for image picker button
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// Text for camera capture button
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Title for import file dialog
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get importFile;

  /// Label for file path input field
  ///
  /// In en, this message translates to:
  /// **'File Path'**
  String get filePath;

  /// Text for file picker button
  ///
  /// In en, this message translates to:
  /// **'Pick File'**
  String get pickFile;

  /// Text for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text for confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Error message when no file is selected for import
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// Message when task is successfully imported
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccess;

  /// Error message when import fails
  ///
  /// In en, this message translates to:
  /// **'Import error'**
  String get importError;

  /// Label for choosing export format
  ///
  /// In en, this message translates to:
  /// **'Choose export format'**
  String get chooseExportFormat;

  /// Label for legacy format option
  ///
  /// In en, this message translates to:
  /// **'Legacy Format'**
  String get legacyFormat;

  /// Label for new format option
  ///
  /// In en, this message translates to:
  /// **'New Format'**
  String get newFormat;

  /// Title for the export page
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Title for tasks tab in export page
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Text for delete action button
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// Title for remove project dialog
  ///
  /// In en, this message translates to:
  /// **'Remove Project'**
  String get removeProject;

  /// Title for remove label dialog
  ///
  /// In en, this message translates to:
  /// **'Remove Label'**
  String get removeLabel;

  /// Text for option selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get chooseOption;

  /// Option to remove related tasks
  ///
  /// In en, this message translates to:
  /// **'Remove related tasks'**
  String get removeRelatedTasks;

  /// Option to only remove project
  ///
  /// In en, this message translates to:
  /// **'Only remove project'**
  String get onlyRemoveProject;

  /// Option to only remove label
  ///
  /// In en, this message translates to:
  /// **'Only remove label'**
  String get onlyRemoveLabel;

  /// Title for export format dialog
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// Option for legacy format export
  ///
  /// In en, this message translates to:
  /// **'Legacy Format (v0)'**
  String get legacyFormatV0;

  /// Option for new format export
  ///
  /// In en, this message translates to:
  /// **'New Format (v1)'**
  String get newFormatV1;

  /// Message when export is successful
  ///
  /// In en, this message translates to:
  /// **'Export Success: {path}'**
  String exportSuccess(String path);

  /// Error message when export fails
  ///
  /// In en, this message translates to:
  /// **'Export Error: {error}'**
  String exportError(String error);

  /// Error message when storage permission is needed
  ///
  /// In en, this message translates to:
  /// **'Storage permissions required'**
  String get storagePermissionRequired;

  /// Label for count column in grids
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// Message shown when no tasks exist
  ///
  /// In en, this message translates to:
  /// **'No Task Added'**
  String get noTaskAdded;

  /// Message shown when a task is marked as completed
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// Message shown when a task is deleted
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Field must not be empty'**
  String get fieldCannotBeEmpty;

  /// No description provided for @valueTooLong.
  ///
  /// In en, this message translates to:
  /// **'Value cannot be longer than {maxLength} characters'**
  String valueTooLong(int maxLength);

  /// Title for import page
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Description text on import page
  ///
  /// In en, this message translates to:
  /// **'Import your tasks from a JSON file exported previously.'**
  String get importDescription;

  /// Text shown during import process
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// Title for import information section
  ///
  /// In en, this message translates to:
  /// **'Import Information'**
  String get importInformation;

  /// Import format support info
  ///
  /// In en, this message translates to:
  /// **'• Supports both v0 (legacy) and v1 (new) format'**
  String get importInfoLegacySupport;

  /// Import auto-detection info
  ///
  /// In en, this message translates to:
  /// **'• Import will automatically detect the format'**
  String get importInfoAutoDetect;

  /// Import tasks info
  ///
  /// In en, this message translates to:
  /// **'• All imported tasks will be added to your task list'**
  String get importInfoTasksAdded;

  /// Import project/label creation info
  ///
  /// In en, this message translates to:
  /// **'• Projects and labels will be created as needed'**
  String get importInfoItemsCreated;

  /// Message shown during data import
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get importingData;

  /// Wait message during import
  ///
  /// In en, this message translates to:
  /// **'Please wait while your data is being imported.'**
  String get importingWait;

  /// Error message when file is not found
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// Error message when file cannot be read
  ///
  /// In en, this message translates to:
  /// **'Cannot read file'**
  String get cannotReadFile;

  /// Error message for invalid JSON format
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format'**
  String get invalidJsonFormat;

  /// Text for go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
