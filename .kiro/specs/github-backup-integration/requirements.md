# Requirements Document

## Introduction

This document specifies the requirements for integrating GitHub repository backup functionality into the Flutter todo application. The feature enables users to export and import their task data (tasks.json) to/from a GitHub repository, with QR code support for easy credential transfer between devices. The implementation uses the `github` package for API interactions, `barcode_scan2` and `barcode_widget` for QR code functionality, and `clipboard` for data export.

## Glossary

- **GitHub_Backup_System**: The complete system that manages GitHub repository credentials, permissions, and data synchronization
- **Credential_Form**: The user interface for entering and managing GitHub repository credentials (token, owner, repo, pathPrefix, branch)
- **QR_Code_Generator**: The component that generates QR codes containing GitHub credentials in JSON format
- **QR_Code_Scanner**: The component that scans and parses QR codes to populate GitHub credentials
- **GitHub_Cubit**: The state management component that handles GitHub credential storage and retrieval using shared_preferences
- **Export_System**: The existing export functionality that will be extended to support GitHub as a destination
- **Import_System**: The existing import functionality that will be extended to support GitHub as a source
- **Settings_Security**: The settings section that controls whether GitHub export/import is enabled
- **Permission_Handler**: The existing utility at lib/utils/permission_handler.dart that manages all app permissions including camera permissions required for QR code scanning
- **GitHub_Config_Model**: The data model in lib/models that represents GitHub repository configuration (token, owner, repo, pathPrefix, branch)

## Requirements

### Requirement 1: GitHub Credential Management

**User Story:** As a user, I want to securely store my GitHub repository credentials so that I can backup and restore my tasks to/from GitHub.

#### Acceptance Criteria

1. THE GitHub_Backup_System SHALL define a GitHub_Config_Model in lib/models with properties for token, owner, repo, pathPrefix, and branch
2. THE GitHub_Config_Model SHALL provide JSON serialization and deserialization methods
3. THE GitHub_Backup_System SHALL provide a Credential_Form with input fields for all GitHub_Config_Model properties
4. WHEN a user enters credentials in the Credential_Form, THE GitHub_Backup_System SHALL validate that all required fields are non-empty
5. THE GitHub_Backup_System SHALL store credentials as a JSON object in shared_preferences using a dedicated key in SettingKeys
6. THE GitHub_Backup_System SHALL support multi-line text input with text wrapping for all credential fields
7. THE GitHub_Backup_System SHALL NOT hardcode any credential values in the source code
8. THE Credential_Form SHALL display all text in English without internationalization suppo

### Requirement 2: QR Code Credential Transfer

**User Story:** As a user, I want to generate and scan QR codes containing my GitHub credentials so that I can easily transfer configuration between my computer and mobile device.

#### Acceptance Criteria

1. WHEN a user completes the Credential_Form, THE QR_Code_Generator SHALL create a QR code image containing credentials in JSON format
2. THE GitHub_Backup_System SHALL display the generated QR code in a dedicated view accessible via a left FAB button
3. WHEN a user taps the right FAB button, THE GitHub_Backup_System SHALL export the credential JSON to the system clipboard
4. THE GitHub_Backup_System SHALL provide an action button in the app bar that displays QR scanning instructions in English
5. WHEN a user confirms the scanning instructions, THE QR_Code_Scanner SHALL activate the device camera to scan QR codes
6. WHEN a QR code is successfully scanned, THE GitHub_Backup_System SHALL parse the JSON data and populate the Credential_Form fields
7. THE QR_Code_Scanner SHALL use JSON format for credential encoding and decoding

### Requirement 3: Camera Permission Management

**User Story:** As a user, I want the app to request camera permissions when needed so that I can scan QR codes for credential import.

#### Acceptance Criteria

1. WHEN a user initiates QR code scanning, THE Permission_Handler SHALL check for camera permission status using the existing lib/utils/permission_handler.dart utility
2. IF camera permission is not granted, THEN THE Permission_Handler SHALL request camera permission from the user
3. IF camera permission is denied, THEN THE GitHub_Backup_System SHALL display an error message and prevent scanning
4. THE Permission_Handler SHALL add a camera permission method to the existing PermissionHandlerService class
5. THE Permission_Handler SHALL add camera permission declarations to AndroidManifest.xml if required by the platform
6. THE Permission_Handler SHALL use the existing permission_handler package integration

### Requirement 4: GitHub Configuration Data Model

**User Story:** As a developer, I want a strongly-typed model for GitHub configuration so that credential data is consistently structured throughout the app.

#### Acceptance Criteria

1. THE GitHub_Config_Model SHALL be defined in lib/models directory
2. THE GitHub_Config_Model SHALL include fields for token, owner, repo, pathPrefix, and branch
3. THE GitHub_Config_Model SHALL provide methods to serialize to JSON format
4. THE GitHub_Config_Model SHALL provide methods to deserialize from JSON format
5. THE GitHub_Config_Model SHALL validate that all required fields are non-empty

### Requirement 5: GitHub Cubit State Management

**User Story:** As a developer, I want a dedicated Cubit to manage GitHub credentials so that the state is properly managed and accessible throughout the app.

#### Acceptance Criteria

1. THE GitHub_Cubit SHALL follow the same pattern as CommentCubit for state management
2. THE GitHub_Cubit SHALL use the GitHub_Config_Model for type-safe state representation
3. THE GitHub_Cubit SHALL load credentials from shared_preferences on initialization
4. WHEN credentials are updated, THE GitHub_Cubit SHALL persist changes to shared_preferences
5. THE GitHub_Cubit SHALL emit state changes when credentials are loaded, updated, or cleared
6. THE GitHub_Cubit SHALL be initialized in main.dart as a BlocProvider with lazy: false

### Requirement 6: Internationalization Exclusion

**User Story:** As a developer, I want to use English text directly in the new GitHub backup UI so that I can deliver the feature quickly without internationalization overhead.

#### Acceptance Criteria

1. THE GitHub_Backup_System SHALL use hardcoded English strings for all UI text
2. THE GitHub_Backup_System SHALL NOT use AppLocalizations for any new UI components
3. THE GitHub_Backup_System SHALL NOT add new translation keys to l10n files
4. THE implementation documentation SHALL note that internationalization is excluded from this feature
5. THE GitHub_Backup_System SHALL use clear, concise English labels and messages

### Requirement 7: Settings Security Integration

**User Story:** As a user, I want to control whether GitHub backup is enabled so that I can manage my data security preferences.

#### Acceptance Criteria

1. THE Settings_Security SHALL provide a toggle switch for enabling/disabling GitHub export functionality
2. THE SettingsBloc SHALL add a new event and state property for the GitHub export toggle
3. THE SettingsBloc SHALL persist the GitHub export enabled state to the database
4. THE SettingKeys SHALL include a new constant for the GitHub export setting key
5. WHEN GitHub export is disabled in settings, THE Export_System SHALL prevent GitHub export operations

### Requirement 8: Export to GitHub Repository

**User Story:** As a user, I want to export my tasks to a GitHub repository so that I can backup my data remotely.

#### Acceptance Criteria

1. WHEN a user initiates export, THE Export_System SHALL display a dialog with destination options including "Local" and "GitHub"
2. THE Export_System SHALL default to "Local" destination and v2 format without format selection
3. WHEN "GitHub" is selected and credentials are not configured, THEN THE Export_System SHALL navigate to the Credential_Form
4. WHEN "GitHub" is selected and GitHub export is disabled in settings, THEN THE Export_System SHALL display a confirmation dialog
5. IF the user confirms the settings dialog, THEN THE Export_System SHALL navigate to the Settings_Security page
6. WHEN export to GitHub is initiated with valid credentials, THE Export_System SHALL upload tasks.json to the specified repository path
7. IF GitHub upload fails, THEN THE Export_System SHALL navigate to an error display page showing the failure details

### Requirement 9: Import from GitHub Repository

**User Story:** As a user, I want to import my tasks from a GitHub repository so that I can restore my data from a remote backup.

#### Acceptance Criteria

1. THE Import_System SHALL provide tabs to switch between "Local" and "GitHub" import sources
2. WHEN "GitHub" tab is selected and credentials are not configured, THEN THE Import_System SHALL navigate to the Credential_Form
3. WHEN "GitHub" tab is selected and GitHub export is disabled in settings, THEN THE Import_System SHALL display a confirmation dialog
4. IF the user confirms the settings dialog, THEN THE Import_System SHALL navigate to the Settings_Security page
5. WHEN import from GitHub is initiated with valid credentials, THE Import_System SHALL download tasks.json from the specified repository path
6. THE Import_System SHALL maintain backward compatibility with legacy import formats
7. IF GitHub download fails, THEN THE Import_System SHALL navigate to an error display page showing the failure details

### Requirement 10: Navigation and Routing

**User Story:** As a user, I want to easily navigate to GitHub credential configuration so that I can set up or modify my backup settings.

#### Acceptance Criteria

1. THE router.dart SHALL register routes for the Credential_Form page
2. THE router.dart SHALL register routes for the QR code display page if implemented as a separate view
3. THE router.dart SHALL register a route for the GitHub error display page
4. THE sidebar Controls section SHALL provide a navigation option to the Credential_Form as a separate section
5. THE sidebar Controls section SHALL visually separate the GitHub configuration from grid and export/import sections

### Requirement 11: GitHub API Integration

**User Story:** As a developer, I want to use the github package to interact with GitHub repositories so that I can upload and download task data.

#### Acceptance Criteria

1. THE GitHub_Backup_System SHALL use the `github` package for all GitHub API interactions
2. WHEN uploading to GitHub, THE GitHub_Backup_System SHALL create or update tasks.json at the specified path and branch
3. WHEN downloading from GitHub, THE GitHub_Backup_System SHALL retrieve tasks.json from the specified path and branch
4. THE GitHub_Backup_System SHALL handle authentication using the provided personal access token
5. THE GitHub_Backup_System SHALL construct file paths using the pathPrefix configuration value

### Requirement 12: Error Handling and User Feedback

**User Story:** As a user, I want clear error messages when GitHub operations fail so that I can understand and resolve issues.

#### Acceptance Criteria

1. WHEN a GitHub operation fails, THE GitHub_Backup_System SHALL capture the error details
2. THE GitHub_Backup_System SHALL display error information in a dedicated error page
3. THE error page SHALL include the error message, operation type, and timestamp
4. THE error page SHALL provide a navigation option to return to the previous screen
5. THE GitHub_Backup_System SHALL log all GitHub operation errors for debugging purposes

### Requirement 13: Flutter and Dart Command Execution

**User Story:** As a developer, I want to ensure all Flutter and Dart commands use fvm so that the project uses the correct Flutter version.

#### Acceptance Criteria

1. THE implementation tasks SHALL specify that all flutter commands must be prefixed with "fvm"
2. THE implementation tasks SHALL specify that all dart commands must be prefixed with "fvm"
3. THE implementation documentation SHALL note the fvm requirement for command execution
4. THE implementation tasks SHALL avoid any hardcoded Flutter or Dart command paths

### Requirement 14: Testing Exclusion

**User Story:** As a developer, I want to focus on implementation without writing tests so that I can deliver the feature quickly for manual testing.

#### Acceptance Criteria

1. THE implementation tasks SHALL NOT include unit test creation tasks
2. THE implementation tasks SHALL NOT include integration test creation tasks
3. THE implementation tasks SHALL NOT include widget test creation tasks
4. THE implementation documentation SHALL note that testing will be performed manually
5. THE implementation tasks SHALL focus exclusively on feature implementation and integration
