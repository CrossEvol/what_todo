// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Export Error: ${error}";

  static String m1(path) => "Export Success: ${path}";

  static String m2(maxLength) =>
      "Value cannot be longer than ${maxLength} characters";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutTitle": MessageLookupByLibrary.simpleMessage("About"),
    "addLabel": MessageLookupByLibrary.simpleMessage("Add Label"),
    "addProject": MessageLookupByLibrary.simpleMessage("Add Project"),
    "addResource": MessageLookupByLibrary.simpleMessage("Add Resource"),
    "addTask": MessageLookupByLibrary.simpleMessage("Add Task"),
    "allToToday": MessageLookupByLibrary.simpleMessage("All to Today"),
    "apacheLicense": MessageLookupByLibrary.simpleMessage("Apache License"),
    "askQuestion": MessageLookupByLibrary.simpleMessage("Ask Question ?"),
    "authorName": MessageLookupByLibrary.simpleMessage("Burhanuddin Rashid"),
    "authorSectionTitle": MessageLookupByLibrary.simpleMessage("Author"),
    "authorUsername": MessageLookupByLibrary.simpleMessage("burhanrashid52"),
    "avatarUrl": MessageLookupByLibrary.simpleMessage("Avatar URL"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotReadFile": MessageLookupByLibrary.simpleMessage("Cannot read file"),
    "chooseExportFormat": MessageLookupByLibrary.simpleMessage(
      "Choose export format",
    ),
    "chooseOption": MessageLookupByLibrary.simpleMessage("Choose an option:"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "completedTasks": MessageLookupByLibrary.simpleMessage("Completed Tasks"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirm Delete"),
    "controls": MessageLookupByLibrary.simpleMessage("Controls"),
    "count": MessageLookupByLibrary.simpleMessage("Count"),
    "delete": MessageLookupByLibrary.simpleMessage("DELETE"),
    "deleteResourceConfirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this resource? This action cannot be undone.",
    ),
    "done": MessageLookupByLibrary.simpleMessage("done"),
    "dueDate": MessageLookupByLibrary.simpleMessage("Due Date"),
    "editTask": MessageLookupByLibrary.simpleMessage("Edit Task"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "exportError": m0,
    "exportFormat": MessageLookupByLibrary.simpleMessage("Export Format"),
    "exportSuccess": m1,
    "exports": MessageLookupByLibrary.simpleMessage("Exports"),
    "failedToLoadLabels": MessageLookupByLibrary.simpleMessage(
      "Failed to load labels",
    ),
    "failedToLoadProjects": MessageLookupByLibrary.simpleMessage(
      "Failed to load projects",
    ),
    "fieldCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Field must not be empty",
    ),
    "fileNotFound": MessageLookupByLibrary.simpleMessage("File not found"),
    "filePath": MessageLookupByLibrary.simpleMessage("File Path"),
    "forkGithub": MessageLookupByLibrary.simpleMessage("Fork on Github"),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "goBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importDescription": MessageLookupByLibrary.simpleMessage(
      "Import your tasks from a JSON file exported previously.",
    ),
    "importError": MessageLookupByLibrary.simpleMessage("Import error"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import File"),
    "importInfoAutoDetect": MessageLookupByLibrary.simpleMessage(
      "• Import will automatically detect the format",
    ),
    "importInfoItemsCreated": MessageLookupByLibrary.simpleMessage(
      "• Projects and labels will be created as needed",
    ),
    "importInfoLegacySupport": MessageLookupByLibrary.simpleMessage(
      "• Supports both v0 (legacy) and v1 (new) format",
    ),
    "importInfoTasksAdded": MessageLookupByLibrary.simpleMessage(
      "• All imported tasks will be added to your task list",
    ),
    "importInformation": MessageLookupByLibrary.simpleMessage(
      "Import Information",
    ),
    "importSuccess": MessageLookupByLibrary.simpleMessage("Import successful"),
    "importing": MessageLookupByLibrary.simpleMessage("Importing..."),
    "importingData": MessageLookupByLibrary.simpleMessage("Importing data..."),
    "importingWait": MessageLookupByLibrary.simpleMessage(
      "Please wait while your data is being imported.",
    ),
    "imports": MessageLookupByLibrary.simpleMessage("Imports"),
    "inbox": MessageLookupByLibrary.simpleMessage("Inbox"),
    "invalidJsonFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid JSON format",
    ),
    "labelAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Label already exists",
    ),
    "labelCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Label Cannot be empty",
    ),
    "labelGrid": MessageLookupByLibrary.simpleMessage("Label Grid"),
    "labelName": MessageLookupByLibrary.simpleMessage("Label Name"),
    "labels": MessageLookupByLibrary.simpleMessage("Labels"),
    "legacyFormat": MessageLookupByLibrary.simpleMessage("Legacy Format"),
    "legacyFormatV0": MessageLookupByLibrary.simpleMessage(
      "Legacy Format (v0)",
    ),
    "licenseText": MessageLookupByLibrary.simpleMessage(
      "Copyright 2020 Burhanuddin Rashid\n\nLicensed under the Apache License, Version 2.0 (the \"License\") you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.",
    ),
    "manageResources": MessageLookupByLibrary.simpleMessage("Manage Resources"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "newFormat": MessageLookupByLibrary.simpleMessage("New Format"),
    "newFormatV1": MessageLookupByLibrary.simpleMessage("New Format (v1)"),
    "next7Days": MessageLookupByLibrary.simpleMessage("Next 7 Days"),
    "noComments": MessageLookupByLibrary.simpleMessage("No Comments"),
    "noFileSelected": MessageLookupByLibrary.simpleMessage("No file selected"),
    "noLabels": MessageLookupByLibrary.simpleMessage("No Labels"),
    "noReminder": MessageLookupByLibrary.simpleMessage("No Reminder"),
    "noResourcesAttached": MessageLookupByLibrary.simpleMessage(
      "No resources attached",
    ),
    "noTaskAdded": MessageLookupByLibrary.simpleMessage("No Task Added"),
    "onlyRemoveLabel": MessageLookupByLibrary.simpleMessage(
      "Only remove label",
    ),
    "onlyRemoveProject": MessageLookupByLibrary.simpleMessage(
      "Only remove project",
    ),
    "orderTest": MessageLookupByLibrary.simpleMessage("OrderTest"),
    "pickFile": MessageLookupByLibrary.simpleMessage("Pick File"),
    "pickImage": MessageLookupByLibrary.simpleMessage("Pick Image"),
    "postponeTasks": MessageLookupByLibrary.simpleMessage("Postpone Tasks"),
    "priority": MessageLookupByLibrary.simpleMessage("Priority"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "projectAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Project already exists",
    ),
    "projectGrid": MessageLookupByLibrary.simpleMessage("Project Grid"),
    "projectName": MessageLookupByLibrary.simpleMessage("Project Name"),
    "projectNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Project name cannot be empty",
    ),
    "projects": MessageLookupByLibrary.simpleMessage("Projects"),
    "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
    "removeLabel": MessageLookupByLibrary.simpleMessage("Remove Label"),
    "removeProject": MessageLookupByLibrary.simpleMessage("Remove Project"),
    "removeRelatedTasks": MessageLookupByLibrary.simpleMessage(
      "Remove related tasks",
    ),
    "reportIssueSubtitle": MessageLookupByLibrary.simpleMessage(
      "Having an issue ? Report it here",
    ),
    "reportIssueTitle": MessageLookupByLibrary.simpleMessage("Report an Issue"),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage("Resource deleted"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "selectLabels": MessageLookupByLibrary.simpleMessage("Select Labels"),
    "selectPriority": MessageLookupByLibrary.simpleMessage("Select Priority"),
    "selectProject": MessageLookupByLibrary.simpleMessage("Select Project"),
    "sendEmail": MessageLookupByLibrary.simpleMessage("Send an Email"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "storagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Storage permissions required",
    ),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Take Photo"),
    "tapAddToAttachImages": MessageLookupByLibrary.simpleMessage(
      "Tap the + button to attach images",
    ),
    "taskCompleted": MessageLookupByLibrary.simpleMessage("Task completed"),
    "taskDeleted": MessageLookupByLibrary.simpleMessage("Task deleted"),
    "taskGrid": MessageLookupByLibrary.simpleMessage("Task Grid"),
    "taskTitle": MessageLookupByLibrary.simpleMessage("Title"),
    "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "titleCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Title Cannot be Empty",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "uncompletedTasks": MessageLookupByLibrary.simpleMessage(
      "Uncompleted Tasks",
    ),
    "undone": MessageLookupByLibrary.simpleMessage("undone"),
    "unknown": MessageLookupByLibrary.simpleMessage("UNKNOWN"),
    "unknownNotImplemented": MessageLookupByLibrary.simpleMessage(
      "Unknown has not implemented.",
    ),
    "valueTooLong": m2,
    "versionTitle": MessageLookupByLibrary.simpleMessage("Version"),
    "viewFullSize": MessageLookupByLibrary.simpleMessage("View full size"),
  };
}
