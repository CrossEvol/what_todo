# Design Document

## Overview

This feature adds a configurable reminder check interval setting to the existing settings system. Users will be able to select from predefined interval options (15 minutes, 30 minutes, 1 hour, 2 hours, 4 hours) through the settings UI. The selected interval will be stored in the database and used to dynamically configure the WorkManager periodic task frequency.

## Architecture

The implementation follows the existing architecture patterns in the app:

- **Settings Layer**: Extends the current settings system with a new `REMINDER_INTERVAL` setting
- **UI Layer**: Adds a new settings tile in the Security section alongside existing notification settings
- **BLoC Layer**: Extends the existing SettingsBloc with new events and state management
- **WorkManager Integration**: Modifies the existing WorkManager setup to use the configurable interval

## Components and Interfaces

### 1. Settings Database Extension

**New Setting Key**:
```dart
// In lib/constants/keys.dart
class SettingKeys {
  // ... existing keys
  static const REMINDER_INTERVAL = 'reminder_interval';
}
```

**Setting Type**: `SettingType.IntNumber` (stores interval in minutes)

**Default Value**: 15 (minutes)

### 2. Settings BLoC Extension

**New Events**:
```dart
// In lib/bloc/settings/settings_event.dart
class ToggleReminderInterval extends SettingsEvent {
  final int intervalMinutes;
  const ToggleReminderInterval({required this.intervalMinutes});
}
```

**State Extension**:
```dart
// In lib/bloc/settings/settings_state.dart
class SettingsState extends Equatable {
  // ... existing properties
  final int reminderInterval;
  
  const SettingsState({
    // ... existing parameters
    this.reminderInterval = 15,
  });
}
```

**BLoC Handler**:
- Validates interval is within acceptable range (15-240 minutes)
- Updates database setting
- Triggers WorkManager reconfiguration
- Emits success/failure state

### 3. UI Components

**Settings Tile**:
- Location: Security section in SettingsScreen
- Type: `SettingsTile.navigation`
- Icon: `Icons.schedule`
- Title: "Reminder Check Interval"
- Value: Display current interval in human-readable format (e.g., "30 minutes", "1 hour")
- Action: Opens interval selection dialog

**Interval Selection Dialog**:
- Similar pattern to existing language/environment dialogs
- Options: 15 min, 30 min, 1 hour, 2 hours, 4 hours
- Shows current selection with checkmark
- Immediate application on selection

### 4. WorkManager Integration

**Modified Setup Function**:
```dart
// In lib/utils/work_manager_util.dart
void setupWorkManager({int? intervalMinutes}) {
  final interval = intervalMinutes ?? 15;
  
  // Cancel existing task
  Workmanager().cancelByUniqueName("1");
  
  // Register with new interval
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: interval),
    // ... other parameters
  );
}
```

**Initialization Update**:
- Read interval setting from database on app startup
- Pass interval to setupWorkManager function
- Handle cases where setting doesn't exist (create default)

## Data Models

### Interval Options Model
```dart
class ReminderInterval {
  final int minutes;
  final String displayName;
  
  const ReminderInterval({
    required this.minutes,
    required this.displayName,
  });
  
  static const List<ReminderInterval> options = [
    ReminderInterval(minutes: 15, displayName: '15 minutes'),
    ReminderInterval(minutes: 30, displayName: '30 minutes'),
    ReminderInterval(minutes: 60, displayName: '1 hour'),
    ReminderInterval(minutes: 120, displayName: '2 hours'),
    ReminderInterval(minutes: 240, displayName: '4 hours'),
  ];
}
```

### Database Schema
No schema changes required - uses existing `setting` table:
- `key`: 'reminder_interval'
- `value`: String representation of minutes (e.g., "30")
- `type`: 'IntNumber'
- `updatedAt`: Current timestamp

## Error Handling

### WorkManager Registration Failures
- **Detection**: Catch exceptions during `registerPeriodicTask`
- **Recovery**: Revert to previous interval setting
- **User Feedback**: Show error snackbar with retry option
- **Logging**: Log failure details for debugging

### Invalid Interval Values
- **Validation**: Ensure interval is within 15-240 minutes range
- **Sanitization**: Default to 15 minutes for invalid values
- **User Feedback**: Show validation error in dialog

### Database Operation Failures
- **Setting Read Failure**: Default to 15 minutes, log warning
- **Setting Write Failure**: Show error message, don't update WorkManager
- **Transaction Rollback**: Ensure consistency between UI state and database

### App Startup Edge Cases
- **Missing Setting**: Create default setting (15 minutes)
- **Corrupted Setting**: Reset to default, log error
- **WorkManager Init Failure**: Continue with app startup, disable notifications

## Testing Strategy

### Unit Tests
1. **SettingsBloc Tests**:
   - Test interval validation logic
   - Test state transitions for valid/invalid intervals
   - Test error handling for database failures

2. **WorkManager Utility Tests**:
   - Test interval parameter handling
   - Test task cancellation and re-registration
   - Mock WorkManager to test error scenarios

3. **Settings Database Tests**:
   - Test CRUD operations for reminder interval setting
   - Test default value creation
   - Test data type conversion (string ↔ int)

### Integration Tests
1. **Settings UI Flow**:
   - Navigate to settings screen
   - Open interval selection dialog
   - Select different intervals
   - Verify UI updates and persistence

2. **WorkManager Integration**:
   - Change interval setting
   - Verify WorkManager task is updated
   - Test app restart with custom interval

3. **End-to-End Notification Flow**:
   - Set custom interval
   - Create reminder
   - Verify notification timing matches interval

### Widget Tests
1. **Settings Screen**:
   - Test interval tile rendering
   - Test dialog opening/closing
   - Test interval selection interaction

2. **Interval Selection Dialog**:
   - Test option rendering
   - Test current selection highlighting
   - Test selection callback

### Performance Considerations
- **WorkManager Overhead**: Frequent task re-registration should be minimal
- **Database Queries**: Cache interval value in memory after first read
- **UI Responsiveness**: Async operations should not block UI thread
- **Battery Impact**: Longer intervals reduce battery usage, shorter intervals increase responsiveness