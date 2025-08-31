# Implementation Plan

- [-] 1. Add reminder interval setting key and data model



  - Add REMINDER_INTERVAL constant to SettingKeys class in keys.dart
  - Create ReminderInterval model class with predefined options and display names
  - _Requirements: 4.3, 4.4_

- [ ] 2. Extend SettingsBloc with reminder interval functionality
  - [ ] 2.1 Add ToggleReminderInterval event class
    - Create new event class in settings_event.dart that accepts intervalMinutes parameter
    - Add proper equality and props implementation for the event
    - _Requirements: 2.1, 2.2_

  - [ ] 2.2 Add reminderInterval property to SettingsState
    - Extend SettingsState class to include reminderInterval field with default value of 15
    - Update copyWith method and equality implementation
    - Update state constructor to handle the new field
    - _Requirements: 3.1, 3.2_

  - [ ] 2.3 Implement reminder interval event handler in SettingsBloc
    - Add event handler for ToggleReminderInterval in SettingsBloc
    - Implement interval validation (15-240 minutes range)
    - Add database update logic using existing SettingsDB pattern
    - Add WorkManager reconfiguration call
    - Implement proper error handling and state emission
    - _Requirements: 2.1, 2.2, 2.3, 4.4_

- [ ] 3. Update SettingsBloc initialization to load reminder interval
  - Modify SettingsBloc constructor or initial state loading to read reminder interval from database
  - Handle case where setting doesn't exist by creating default setting
  - Add error handling for database read failures
  - _Requirements: 4.1, 4.2_

- [ ] 4. Modify WorkManager utility to accept configurable interval
  - [ ] 4.1 Update setupWorkManager function signature
    - Add optional intervalMinutes parameter to setupWorkManager function
    - Implement task cancellation before registering new task with updated interval
    - Add error handling for WorkManager registration failures
    - _Requirements: 2.1, 2.2_

  - [ ] 4.2 Update app initialization to use stored interval
    - Modify main.dart or app initialization to read interval setting from database
    - Pass the stored interval to setupWorkManager function
    - Handle cases where no setting exists by using default value
    - _Requirements: 4.1, 4.2_

- [ ] 5. Create interval selection UI components
  - [ ] 5.1 Add reminder interval settings tile to SettingsScreen
    - Add new SettingsTile.navigation in Security section of settings_screen.dart
    - Implement proper key, icon, title, and value display
    - Add onPressed handler to open interval selection dialog
    - Display current interval in human-readable format
    - _Requirements: 1.1, 3.1_

  - [ ] 5.2 Implement interval selection dialog
    - Create _toggleReminderInterval method in SettingsScreen following existing pattern
    - Build dialog with ReminderInterval.options list
    - Implement selection handling that dispatches ToggleReminderInterval event
    - Add visual indication of currently selected interval
    - _Requirements: 1.2, 2.3_

- [ ] 6. Add WorkManager reconfiguration helper
  - Create helper method in work_manager_util.dart to handle interval changes
  - Implement proper task cancellation and re-registration logic
  - Add error handling and logging for WorkManager operations
  - _Requirements: 2.1, 2.2_

