# Implementation Plan

- [x] 1. Add dependencies and update configuration files
  - Add github, barcode_scan2, barcode_widget, and clipboard packages using `fvm flutter pub add`
  - Add camera permission to AndroidManifest.xml
  - Run `fvm flutter pub get` to install dependencies
  - _Requirements: 2.7, 3.4, 3.5, 11.1_

- [x] 2. Create GitHub configuration data model
  - Create lib/models/github_config.dart with GitHubConfig class
  - Implement fields: token, owner, repo, pathPrefix, branch
  - Implement toMap() and fromMap() methods for serialization
  - Implement isValid() validation method
  - Implement empty() factory constructor
  - Implement copyWith() method
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 3. Add GitHub configuration key to constants
  - Update lib/constants/keys.dart to add GITHUB_CONFIG and ENABLE_GITHUB_EXPORT to SettingKeys
  - _Requirements: 5.4, 7.3_

- [x] 4. Implement GitHub Cubit for state management
  - Create lib/cubit/github_cubit.dart following CommentCubit pattern
  - Implement state as GitHubConfig
  - Implement _loadConfig() to load from shared_preferences on initialization
  - Implement updateConfig() to save and emit new config
  - Implement clearConfig() to remove config
  - Implement isConfigured getter
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5. Initialize GitHub Cubit in main.dart
  - Add GitHubCubit to BlocProvider list in main.dart
  - Set lazy: false to load config on app start
  - _Requirements: 5.6_

- [x] 6. Enhance PermissionHandlerService with camera permission methods
  - Add hasCameraPermission() method to lib/utils/permission_handler.dart
  - Add requestCameraPermission() method
  - Add showCameraPermissionDialog() static method
  - Add checkAndRequestCameraPermission() method with UI flow
  - Follow existing permission handler patterns
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.6_

- [x] 7. Create QR Code Service
  - Create lib/services/qr_code_service.dart
  - Implement generateQRData() to convert GitHubConfig to JSON string
  - Implement parseQRData() to parse JSON string to GitHubConfig
  - Implement scanQRCode() using barcode_scan2 package
  - Add error handling for invalid QR codes
  - _Requirements: 2.1, 2.6, 2.7_

- [x] 8. Create GitHub Service for API interactions
  - Create lib/services/github_service.dart
  - Implement uploadTasksJson() method to upload tasks.json to GitHub repository
  - Implement downloadTasksJson() method to download tasks.json from GitHub repository
  - Implement _constructFilePath() helper to build file paths with prefix
  - Handle file creation and updates (check for existing SHA)
  - Add proper error handling and logging
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 9. Create GitHub configuration form page
  - Create lib/pages/github/github_config_page.dart
  - Implement form with TextFields for token, owner, repo, pathPrefix, branch
  - Use multi-line TextField with wrapping for token input
  - Add validation for required fields
  - Add info button in AppBar to show QR scanning instructions
  - Add left FAB to generate and display QR code
  - Add right FAB to copy config JSON to clipboard using clipboard package
  - Use English text only (no internationalization)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.3, 2.4, 6.1, 6.2, 6.3, 6.4_

- [x] 10. Create QR code display page
  - Create lib/pages/github/github_qr_display_page.dart
  - Use barcode_widget to display QR code from GitHubConfig
  - Add descriptive text explaining the QR code purpose
  - Add close button to return to config form
  - Use English text only
  - _Requirements: 2.2, 6.1_

- [x] 11. Implement QR scanning instructions dialog
  - Add method to show QR scanning instructions dialog in github_config_page.dart
  - Display instructions in English about QR code scanning process
  - Add "Understood, Go Scan" button that triggers camera permission check
  - Call QRCodeService.scanQRCode() after permission granted
  - Parse scanned data and populate form fields
  - Handle scan errors and invalid QR codes
  - _Requirements: 2.4, 2.5, 2.6, 6.1_

- [x] 12. Create GitHub error display page
  - Create lib/pages/github/github_error_page.dart
  - Display error message, operation type, and timestamp
  - Add icon and styled error container
  - Add "Go Back" button to return to previous screen
  - Use English text only
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 13. Add GitHub export toggle to Settings
  - Add enableGitHubExport field to SettingsState in lib/bloc/settings/settings_bloc.dart
  - Create ToggleEnableGitHubExport event
  - Implement _toggleEnableGitHubExport event handler
  - Update state initialization with default value (false)
  - Update copyWith method to include enableGitHubExport
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 14. Add GitHub export toggle to Settings UI
  - Add SettingsTile.switchTile for GitHub export in lib/pages/settings/settings_screen.dart
  - Place in Security section
  - Use English text: "Enable GitHub Export" with description
  - Use cloud_upload icon
  - Wire to ToggleEnableGitHubExport event
  - _Requirements: 7.5_

- [x] 15. Enhance Export page with GitHub destination option
  - Update lib/pages/export/export_page.dart to show destination selection dialog
  - Add radio buttons for "Local Storage" and "GitHub Repository"
  - Default to "Local Storage"
  - Remove format selection (always use v2)
  - Check if GitHub is selected and credentials are not configured, navigate to github_config page
  - Check if GitHub export is disabled in settings, show confirmation dialog
  - If user confirms settings dialog, navigate to settings page
  - Use English text only
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 16. Implement GitHub export functionality in ExportBloc
  - Update lib/bloc/export/export_bloc.dart to handle GitHub export
  - Add ExportToGitHubEvent
  - Implement _exportToGitHub event handler
  - Use GitHubService to upload tasks.json
  - Handle success and error states
  - Navigate to error page on failure with error details
  - _Requirements: 8.6, 8.7_

- [x] 17. Enhance Import page with GitHub tab
  - Update lib/pages/import/import_page.dart to add tabs for "Local" and "GitHub"
  - Implement tab switching UI
  - Add GitHub tab content with repository info display
  - Add "Load from GitHub" button
  - Check if GitHub is selected and credentials are not configured, navigate to github_config page
  - Check if GitHub export is disabled in settings, show confirmation dialog
  - If user confirms settings dialog, navigate to settings page
  - Use English text only
  - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 18. Implement GitHub import functionality in ImportBloc
  - Update lib/bloc/import/import_bloc.dart to handle GitHub import
  - Add ImportFromGitHubEvent
  - Implement _importFromGitHub event handler
  - Use GitHubService to download tasks.json
  - Parse JSON and emit ImportLoaded state
  - Maintain backward compatibility with legacy formats
  - Navigate to error page on failure with error details
  - _Requirements: 9.5, 9.6, 9.7_

- [x] 19. Add routes for GitHub pages
  - Update lib/router/router.dart to add route for github_config page
  - Add route for github_qr_display page (pass GitHubConfig as extra)
  - Add route for github_error page (pass error details as extra)
  - _Requirements: 10.1, 10.2, 10.3_

- [x] 20. Add GitHub configuration to sidebar Controls
  - Update sidebar drawer to add new "GitHub Configuration" section
  - Add visual separator between Export/Import and GitHub Configuration
  - Add navigation item "Setup GitHub Backup" that navigates to github_config page
  - Use English text only
  - _Requirements: 10.4, 10.5_
