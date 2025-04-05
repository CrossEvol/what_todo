// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Inbox`
  String get inbox {
    return Intl.message(
      'Inbox',
      name: 'inbox',
      desc: 'Title for the inbox menu item',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: 'Title for the today menu item',
      args: [],
    );
  }

  /// `Next 7 Days`
  String get next7Days {
    return Intl.message(
      'Next 7 Days',
      name: 'next7Days',
      desc: 'Title for the next 7 days menu item',
      args: [],
    );
  }

  /// `Project Grid`
  String get projectGrid {
    return Intl.message(
      'Project Grid',
      name: 'projectGrid',
      desc: 'Title for the project grid view',
      args: [],
    );
  }

  /// `Label Grid`
  String get labelGrid {
    return Intl.message(
      'Label Grid',
      name: 'labelGrid',
      desc: 'Title for the label grid view',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Title for the settings menu item',
      args: [],
    );
  }

  /// `OrderTest`
  String get orderTest {
    return Intl.message(
      'OrderTest',
      name: 'orderTest',
      desc:
          'Title for the order test menu item (only shown in test environment)',
      args: [],
    );
  }

  /// `UNKNOWN`
  String get unknown {
    return Intl.message(
      'UNKNOWN',
      name: 'unknown',
      desc: 'Title for the unknown menu item',
      args: [],
    );
  }

  /// `Unknown has not implemented.`
  String get unknownNotImplemented {
    return Intl.message(
      'Unknown has not implemented.',
      name: 'unknownNotImplemented',
      desc: 'Message shown when unknown feature is clicked',
      args: [],
    );
  }

  /// `About`
  String get aboutTitle {
    return Intl.message(
      'About',
      name: 'aboutTitle',
      desc: 'Title for the about screen',
      args: [],
    );
  }

  /// `Report an Issue`
  String get reportIssueTitle {
    return Intl.message(
      'Report an Issue',
      name: 'reportIssueTitle',
      desc: 'Title for report issue section',
      args: [],
    );
  }

  /// `Having an issue ? Report it here`
  String get reportIssueSubtitle {
    return Intl.message(
      'Having an issue ? Report it here',
      name: 'reportIssueSubtitle',
      desc: 'Subtitle for report issue section',
      args: [],
    );
  }

  /// `Version`
  String get versionTitle {
    return Intl.message(
      'Version',
      name: 'versionTitle',
      desc: 'Title for version section',
      args: [],
    );
  }

  /// `Author`
  String get authorSectionTitle {
    return Intl.message(
      'Author',
      name: 'authorSectionTitle',
      desc: 'Title for author section',
      args: [],
    );
  }

  /// `Burhanuddin Rashid`
  String get authorName {
    return Intl.message(
      'Burhanuddin Rashid',
      name: 'authorName',
      desc: 'Name of the author',
      args: [],
    );
  }

  /// `burhanrashid52`
  String get authorUsername {
    return Intl.message(
      'burhanrashid52',
      name: 'authorUsername',
      desc: 'Username of the author',
      args: [],
    );
  }

  /// `Fork on Github`
  String get forkGithub {
    return Intl.message(
      'Fork on Github',
      name: 'forkGithub',
      desc: 'Text for Github fork button',
      args: [],
    );
  }

  /// `Send an Email`
  String get sendEmail {
    return Intl.message(
      'Send an Email',
      name: 'sendEmail',
      desc: 'Text for email button',
      args: [],
    );
  }

  /// `Ask Question ?`
  String get askQuestion {
    return Intl.message(
      'Ask Question ?',
      name: 'askQuestion',
      desc: 'Title for social media section',
      args: [],
    );
  }

  /// `Apache License`
  String get apacheLicense {
    return Intl.message(
      'Apache License',
      name: 'apacheLicense',
      desc: 'Title for license section',
      args: [],
    );
  }

  /// `Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the "License") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.`
  String get licenseText {
    return Intl.message(
      'Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the "License") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.',
      name: 'licenseText',
      desc: 'Full license text',
      args: [],
    );
  }

  /// `Projects`
  String get projects {
    return Intl.message(
      'Projects',
      name: 'projects',
      desc: 'Title for the projects section',
      args: [],
    );
  }

  /// `Add Project`
  String get addProject {
    return Intl.message(
      'Add Project',
      name: 'addProject',
      desc: 'Text for add project button',
      args: [],
    );
  }

  /// `Labels`
  String get labels {
    return Intl.message(
      'Labels',
      name: 'labels',
      desc: 'Title for the labels section',
      args: [],
    );
  }

  /// `Add Label`
  String get addLabel {
    return Intl.message(
      'Add Label',
      name: 'addLabel',
      desc: 'Text for add label button',
      args: [],
    );
  }

  /// `Failed to load projects`
  String get failedToLoadProjects {
    return Intl.message(
      'Failed to load projects',
      name: 'failedToLoadProjects',
      desc: 'Error message when projects fail to load',
      args: [],
    );
  }

  /// `Failed to load labels`
  String get failedToLoadLabels {
    return Intl.message(
      'Failed to load labels',
      name: 'failedToLoadLabels',
      desc: 'Error message when labels fail to load',
      args: [],
    );
  }

  /// `Add Task`
  String get addTask {
    return Intl.message(
      'Add Task',
      name: 'addTask',
      desc: 'Title for add task screen',
      args: [],
    );
  }

  /// `Title`
  String get taskTitle {
    return Intl.message(
      'Title',
      name: 'taskTitle',
      desc: 'Label for task title input field',
      args: [],
    );
  }

  /// `Title Cannot be Empty`
  String get titleCannotBeEmpty {
    return Intl.message(
      'Title Cannot be Empty',
      name: 'titleCannotBeEmpty',
      desc: 'Validation message for empty task title',
      args: [],
    );
  }

  /// `Project`
  String get project {
    return Intl.message(
      'Project',
      name: 'project',
      desc: 'Label for project selection',
      args: [],
    );
  }

  /// `Edit Task`
  String get editTask {
    return Intl.message(
      'Edit Task',
      name: 'editTask',
      desc: 'Title for edit task screen',
      args: [],
    );
  }

  /// `Due Date`
  String get dueDate {
    return Intl.message(
      'Due Date',
      name: 'dueDate',
      desc: 'Label for due date selection',
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message(
      'Priority',
      name: 'priority',
      desc: 'Label for priority selection',
      args: [],
    );
  }

  /// `Select Priority`
  String get selectPriority {
    return Intl.message(
      'Select Priority',
      name: 'selectPriority',
      desc: 'Title for priority selection dialog',
      args: [],
    );
  }

  /// `Select Project`
  String get selectProject {
    return Intl.message(
      'Select Project',
      name: 'selectProject',
      desc: 'Title for project selection dialog',
      args: [],
    );
  }

  /// `Select Labels`
  String get selectLabels {
    return Intl.message(
      'Select Labels',
      name: 'selectLabels',
      desc: 'Title for labels selection dialog',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message(
      'Comments',
      name: 'comments',
      desc: 'Label for comments section',
      args: [],
    );
  }

  /// `No Comments`
  String get noComments {
    return Intl.message(
      'No Comments',
      name: 'noComments',
      desc: 'Text shown when no comments exist',
      args: [],
    );
  }

  /// `Reminder`
  String get reminder {
    return Intl.message(
      'Reminder',
      name: 'reminder',
      desc: 'Label for reminder section',
      args: [],
    );
  }

  /// `No Reminder`
  String get noReminder {
    return Intl.message(
      'No Reminder',
      name: 'noReminder',
      desc: 'Text shown when no reminder is set',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message(
      'Coming Soon',
      name: 'comingSoon',
      desc: 'Text shown for features that are not yet implemented',
      args: [],
    );
  }

  /// `No Labels`
  String get noLabels {
    return Intl.message(
      'No Labels',
      name: 'noLabels',
      desc: 'Text shown when no labels are selected',
      args: [],
    );
  }

  /// `Label Name`
  String get labelName {
    return Intl.message(
      'Label Name',
      name: 'labelName',
      desc: 'Label for label name input field',
      args: [],
    );
  }

  /// `Label Cannot be empty`
  String get labelCannotBeEmpty {
    return Intl.message(
      'Label Cannot be empty',
      name: 'labelCannotBeEmpty',
      desc: 'Validation message for empty label name',
      args: [],
    );
  }

  /// `Label already exists`
  String get labelAlreadyExists {
    return Intl.message(
      'Label already exists',
      name: 'labelAlreadyExists',
      desc: 'Error message when creating duplicate label',
      args: [],
    );
  }

  /// `Project Name`
  String get projectName {
    return Intl.message(
      'Project Name',
      name: 'projectName',
      desc: 'Label for project name input field',
      args: [],
    );
  }

  /// `Project name cannot be empty`
  String get projectNameCannotBeEmpty {
    return Intl.message(
      'Project name cannot be empty',
      name: 'projectNameCannotBeEmpty',
      desc: 'Validation message for empty project name',
      args: [],
    );
  }

  /// `Completed Tasks`
  String get completedTasks {
    return Intl.message(
      'Completed Tasks',
      name: 'completedTasks',
      desc: 'Text for completed tasks menu item',
      args: [],
    );
  }

  /// `Uncompleted Tasks`
  String get uncompletedTasks {
    return Intl.message(
      'Uncompleted Tasks',
      name: 'uncompletedTasks',
      desc: 'Text for uncompleted tasks menu item',
      args: [],
    );
  }

  /// `All to Today`
  String get allToToday {
    return Intl.message(
      'All to Today',
      name: 'allToToday',
      desc: 'Text for moving all tasks to today menu item',
      args: [],
    );
  }

  /// `Postpone Tasks`
  String get postponeTasks {
    return Intl.message(
      'Postpone Tasks',
      name: 'postponeTasks',
      desc: 'Text for postpone tasks menu item',
      args: [],
    );
  }

  /// `Exports`
  String get exports {
    return Intl.message(
      'Exports',
      name: 'exports',
      desc: 'Text for exports menu item',
      args: [],
    );
  }

  /// `Imports`
  String get imports {
    return Intl.message(
      'Imports',
      name: 'imports',
      desc: 'Text for imports menu item',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Title for the profile page',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Label for name input field',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: 'Label for email input field',
      args: [],
    );
  }

  /// `Avatar URL`
  String get avatarUrl {
    return Intl.message(
      'Avatar URL',
      name: 'avatarUrl',
      desc: 'Label for avatar URL input field',
      args: [],
    );
  }

  /// `Pick Image`
  String get pickImage {
    return Intl.message(
      'Pick Image',
      name: 'pickImage',
      desc: 'Text for image picker button',
      args: [],
    );
  }

  /// `Take Photo`
  String get takePhoto {
    return Intl.message(
      'Take Photo',
      name: 'takePhoto',
      desc: 'Text for camera capture button',
      args: [],
    );
  }

  /// `Import File`
  String get importFile {
    return Intl.message(
      'Import File',
      name: 'importFile',
      desc: 'Title for import file dialog',
      args: [],
    );
  }

  /// `File Path`
  String get filePath {
    return Intl.message(
      'File Path',
      name: 'filePath',
      desc: 'Label for file path input field',
      args: [],
    );
  }

  /// `Pick File`
  String get pickFile {
    return Intl.message(
      'Pick File',
      name: 'pickFile',
      desc: 'Text for file picker button',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Text for cancel button',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'Text for confirm button',
      args: [],
    );
  }

  /// `No file selected`
  String get noFileSelected {
    return Intl.message(
      'No file selected',
      name: 'noFileSelected',
      desc: 'Error message when no file is selected',
      args: [],
    );
  }

  /// `No Task Added`
  String get noTaskAdded {
    return Intl.message(
      'No Task Added',
      name: 'noTaskAdded',
      desc: 'Message shown when no tasks exist',
      args: [],
    );
  }

  /// `Task completed`
  String get taskCompleted {
    return Intl.message(
      'Task completed',
      name: 'taskCompleted',
      desc: 'Message shown when a task is marked as completed',
      args: [],
    );
  }

  /// `Task deleted`
  String get taskDeleted {
    return Intl.message(
      'Task deleted',
      name: 'taskDeleted',
      desc: 'Message shown when a task is deleted',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
