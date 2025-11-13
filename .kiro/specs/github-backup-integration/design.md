# Design Document: GitHub Backup Integration

## Overview

This design document outlines the technical approach for integrating GitHub repository backup functionality into the Flutter todo application. The feature enables users to export and import task data (tasks.json) to/from a GitHub repository, with QR code support for easy credential transfer between devices.

### Key Technologies
- **github** package: GitHub API interactions
- **barcode_scan2**: QR code scanning
- **barcode_widget**: QR code generation
- **clipboard**: Clipboard operations
- **permission_handler**: Camera permission management (existing)
- **shared_preferences**: Credential storage (existing)

### Design Principles
- Follow existing patterns (CommentCubit, PermissionHandlerService)
- English-only UI (no internationalization)
- Use fvm for all Flutter/Dart commands
- No test implementation (manual testing only)
- Extend existing export/import functionality

## Architecture

### High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
├──────────────────┬──────────────────┬───────────────────────┤
│ GitHub Config    │  QR Code Pages   │  Export/Import Pages  │
│ Form Page        │  (Generate/Scan) │  (Enhanced)           │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      State Management                        │
├──────────────────┬──────────────────┬───────────────────────┤
│ GitHub Cubit     │  Export Bloc     │  Import Bloc          │
│ (New)            │  (Enhanced)      │  (Enhanced)           │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
├──────────────────┬──────────────────┬───────────────────────┤
│ GitHub Service   │  QR Code Service │  Permission Handler   │
│ (New)            │  (New)           │  (Enhanced)           │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
├──────────────────┬──────────────────┬───────────────────────┤
│ GitHub Config    │  Shared Prefs    │  Settings DB          │
│ Model (New)      │  (Existing)      │  (Enhanced)           │
└──────────────────┴──────────────────┴───────────────────────┘
```

## Components and Interfaces

### 1. Data Models

#### GitHubConfig Model
**Location:** `lib/models/github_config.dart`

```dart
class GitHubConfig {
  final String token;
  final String owner;
  final String repo;
  final String pathPrefix;
  final String branch;

  GitHubConfig({
    required this.token,
    required this.owner,
    required this.repo,
    required this.pathPrefix,
    required this.branch,
  });

  // Validation
  bool isValid() {
    return token.isNotEmpty &&
           owner.isNotEmpty &&
           repo.isNotEmpty &&
           branch.isNotEmpty;
  }

  // Map serialization
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'owner': owner,
      'repo': repo,
      'pathPrefix': pathPrefix,
      'branch': branch,
    };
  }

  // Map deserialization
  factory GitHubConfig.fromMap(Map<String, dynamic> map) {
    return GitHubConfig(
      token: map['token'] ?? '',
      owner: map['owner'] ?? '',
      repo: map['repo'] ?? '',
      pathPrefix: map['pathPrefix'] ?? '/',
      branch: map['branch'] ?? 'master',
    );
  }

  // Empty config
  factory GitHubConfig.empty() {
    return GitHubConfig(
      token: '',
      owner: '',
      repo: '',
      pathPrefix: '/',
      branch: 'master',
    );
  }

  // Copy with
  GitHubConfig copyWith({
    String? token,
    String? owner,
    String? repo,
    String? pathPrefix,
    String? branch,
  }) {
    return GitHubConfig(
      token: token ?? this.token,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      pathPrefix: pathPrefix ?? this.pathPrefix,
      branch: branch ?? this.branch,
    );
  }
}
```

### 2. State Management

#### GitHubCubit
**Location:** `lib/cubit/github_cubit.dart`

**Pattern:** Follows CommentCubit pattern

```dart
class GitHubCubit extends Cubit<GitHubConfig> {
  GitHubCubit() : super(GitHubConfig.empty()) {
    _loadConfig();
  }

  // Load config from shared_preferences
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(SettingKeys.GITHUB_CONFIG);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final map = jsonDecode(jsonString);
        emit(GitHubConfig.fromMap(map));
      } catch (e) {
        logger.error('Failed to load GitHub config: $e');
      }
    }
  }

  // Update config
  Future<void> updateConfig(GitHubConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SettingKeys.GITHUB_CONFIG,
      jsonEncode(config.toMap()),
    );
    emit(config);
  }

  // Clear config
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SettingKeys.GITHUB_CONFIG);
    emit(GitHubConfig.empty());
  }

  // Check if configured
  bool get isConfigured => state.isValid();
}
```

**Integration in main.dart:**
```dart
BlocProvider(
  create: (_) => GitHubCubit(),
  lazy: false,
),
```

### 3. Services

#### GitHubService
**Location:** `lib/services/github_service.dart`

**Responsibilities:**
- Upload tasks.json to GitHub repository
- Download tasks.json from GitHub repository
- Handle GitHub API authentication
- Construct proper file paths

```dart
class GitHubService {
  // Upload tasks.json to GitHub
  Future<void> uploadTasksJson({
    required GitHubConfig config,
    required String jsonContent,
  }) async {
    final github = GitHub(auth: Authentication.withToken(config.token));
    
    try {
      final slug = RepositorySlug(config.owner, config.repo);
      final filePath = _constructFilePath(config.pathPrefix, 'tasks.json');
      
      // Get current file SHA if it exists (for update)
      String? sha;
      try {
        final existingFile = await github.repositories.getContents(
          slug,
          filePath,
          ref: config.branch,
        );
        if (existingFile.file != null) {
          sha = existingFile.file!.sha;
        }
      } catch (e) {
        // File doesn't exist, will create new
      }
      
      // Create or update file
      await github.repositories.createFile(
        slug,
        CreateFile(
          path: filePath,
          message: 'Update tasks.json - ${DateTime.now().toIso8601String()}',
          content: base64Encode(utf8.encode(jsonContent)),
          branch: config.branch,
          sha: sha,
        ),
      );
    } finally {
      github.dispose();
    }
  }

  // Download tasks.json from GitHub
  Future<String> downloadTasksJson({
    required GitHubConfig config,
  }) async {
    final github = GitHub(auth: Authentication.withToken(config.token));
    
    try {
      final slug = RepositorySlug(config.owner, config.repo);
      final filePath = _constructFilePath(config.pathPrefix, 'tasks.json');
      
      final contents = await github.repositories.getContents(
        slug,
        filePath,
        ref: config.branch,
      );
      
      if (contents.file == null) {
        throw Exception('tasks.json not found in repository');
      }
      
      final decodedContent = utf8.decode(
        base64Decode(contents.file!.content!.replaceAll('\n', '')),
      );
      
      return decodedContent;
    } finally {
      github.dispose();
    }
  }

  // Construct file path with prefix
  String _constructFilePath(String prefix, String filename) {
    if (prefix.isEmpty || prefix == '/') {
      return filename;
    }
    
    // Normalize prefix
    String normalizedPrefix = prefix;
    if (normalizedPrefix.startsWith('/')) {
      normalizedPrefix = normalizedPrefix.substring(1);
    }
    if (!normalizedPrefix.endsWith('/')) {
      normalizedPrefix += '/';
    }
    
    return '$normalizedPrefix$filename';
  }
}
```

#### QRCodeService
**Location:** `lib/services/qr_code_service.dart`

**Responsibilities:**
- Generate QR code from GitHubConfig
- Scan QR code and parse to GitHubConfig
- Handle QR code encoding/decoding

```dart
class QRCodeService {
  // Generate QR code data from config
  String generateQRData(GitHubConfig config) {
    return jsonEncode(config.toMap());
  }

  // Parse QR code data to config
  GitHubConfig parseQRData(String qrData) {
    try {
      final map = jsonDecode(qrData);
      return GitHubConfig.fromMap(map);
    } catch (e) {
      throw Exception('Invalid QR code format: $e');
    }
  }

  // Scan QR code
  Future<String?> scanQRCode() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        return result.rawContent;
      }
      return null;
    } catch (e) {
      logger.error('QR scan error: $e');
      return null;
    }
  }
}
```

### 4. Permission Handler Enhancement

**Location:** `lib/utils/permission_handler.dart` (existing file)

**New Methods to Add:**

```dart
// Add to PermissionHandlerService class

/// Check camera permission status
Future<bool> hasCameraPermission() async {
  if (!Platform.isAndroid) return true;

  try {
    final status = await Permission.camera.status;
    return status.isGranted;
  } catch (e) {
    logger.error('Error checking camera permission: $e');
    return false;
  }
}

/// Request camera permission
Future<bool> requestCameraPermission() async {
  if (!Platform.isAndroid) return true;

  try {
    logger.info('Requesting camera permission');
    final status = await Permission.camera.request();
    
    switch (status) {
      case PermissionStatus.granted:
        logger.info('Camera permission granted');
        return true;
      case PermissionStatus.denied:
        logger.warn('Camera permission denied');
        return false;
      case PermissionStatus.permanentlyDenied:
        logger.warn('Camera permission permanently denied');
        return false;
      case PermissionStatus.restricted:
        logger.warn('Camera permission restricted');
        return false;
      default:
        logger.warn('Camera permission status: $status');
        return false;
    }
  } catch (e) {
    logger.error('Error requesting camera permission: $e');
    return false;
  }
}

/// Show camera permission explanation dialog
static Future<bool> showCameraPermissionDialog(BuildContext context) async {
  return await showPermissionDialog(
    context: context,
    title: 'Camera Permission Required',
    message: 'Camera access is needed to scan QR codes for GitHub configuration. '
             'This allows you to quickly import settings from another device.',
    confirmText: 'Grant Permission',
  );
}

/// Check and request camera permission with UI flow
Future<bool> checkAndRequestCameraPermission(BuildContext context) async {
  if (!Platform.isAndroid) return true;

  try {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(context);
      return false;
    }

    // Show explanation dialog
    final shouldRequest = await PermissionHandlerService.showCameraPermissionDialog(context);
    if (!shouldRequest) return false;

    // Request permission
    final granted = await requestCameraPermission();
    if (!granted) {
      _showPermissionDeniedDialog(context, 'Camera Permission');
      return false;
    }

    return true;
  } catch (e) {
    logger.error('Error checking/requesting camera permission: $e');
    return false;
  }
}
```

**AndroidManifest.xml Update:**
Add camera permission declaration:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### 5. Settings Integration

#### SettingKeys Enhancement
**Location:** `lib/constants/keys.dart`

```dart
class SettingKeys {
  // ... existing keys ...
  static const GITHUB_CONFIG = 'github_config';
  static const ENABLE_GITHUB_EXPORT = 'enable_github_export';
}
```

#### SettingsBloc Enhancement
**Location:** `lib/bloc/settings/settings_bloc.dart`

**New Event:**
```dart
class ToggleEnableGitHubExport extends SettingsEvent {}
```

**State Update:**
```dart
class SettingsState extends Equatable {
  // ... existing fields ...
  final bool enableGitHubExport;
  
  // ... constructor and copyWith updates ...
}
```

**Event Handler:**
```dart
FutureOr<void> _toggleEnableGitHubExport(
    ToggleEnableGitHubExport event, Emitter<SettingsState> emit) async {
  final setting = await _settingsDB.findByName(SettingKeys.ENABLE_GITHUB_EXPORT);
  if (setting == null) return;
  
  _settingsDB.updateSetting(Setting.update(
      id: setting.id,
      key: setting.key,
      value: '${!bool.parse(setting.value)}',
      updatedAt: DateTime.now(),
      type: setting.type));
      
  emit(state.copyWith(
    enableGitHubExport: !state.enableGitHubExport,
    updatedKey: SettingKeys.ENABLE_GITHUB_EXPORT,
    status: ResultStatus.success,
  ));
}
```

#### Settings Screen Enhancement
**Location:** `lib/pages/settings/settings_screen.dart`

Add new tile in Security section:
```dart
SettingsTile.switchTile(
  key: ValueKey(SettingKeys.ENABLE_GITHUB_EXPORT),
  onToggle: (value) {
    context.read<SettingsBloc>().add(ToggleEnableGitHubExport());
  },
  initialValue: state.enableGitHubExport,
  leading: const Icon(Icons.cloud_upload),
  title: const Text('Enable GitHub Export'),
  description: const Text('Allow exporting and importing tasks to/from GitHub'),
),
```

## Data Models

### GitHubConfig
- **Fields:** token, owner, repo, pathPrefix, branch
- **Validation:** All fields except pathPrefix are required
- **Serialization:** Map format using toMap/fromMap methods for storage and QR codes
- **Storage:** shared_preferences via SettingKeys.GITHUB_CONFIG (JSON encoded map)

### Export/Import Data Format
- **Format:** JSON (v2 format, existing)
- **Filename:** tasks.json
- **Location:** GitHub repository at specified path
- **Compatibility:** Maintains backward compatibility with legacy formats

## Error Handling

### Error Display Page
**Location:** `lib/pages/github/github_error_page.dart`

```dart
class GitHubErrorPage extends StatelessWidget {
  final String errorMessage;
  final String operation; // 'upload' or 'download'
  final DateTime timestamp;

  const GitHubErrorPage({
    Key? key,
    required this.errorMessage,
    required this.operation,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Operation Failed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 24),
            Text(
              'Operation: ${operation.toUpperCase()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Error Message:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Timestamp: ${timestamp.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Error Handling Strategy

1. **GitHub API Errors:**
   - Network errors: Display error page with retry option
   - Authentication errors: Prompt to check credentials
   - File not found: Clear error message
   - Rate limiting: Inform user to wait

2. **QR Code Errors:**
   - Invalid format: Show error snackbar
   - Camera permission denied: Show permission dialog
   - Scan cancelled: Silent failure, return to form

3. **Validation Errors:**
   - Empty fields: Inline validation messages
   - Invalid JSON: Parse error display
   - Missing config: Navigate to config form

## Testing Strategy

**Note:** Per requirements, no automated tests will be implemented. Testing will be performed manually.

### Manual Testing Checklist

1. **GitHub Configuration:**
   - [ ] Enter valid credentials
   - [ ] Validate required fields
   - [ ] Save and load from shared_preferences
   - [ ] Clear configuration

2. **QR Code Functionality:**
   - [ ] Generate QR code from config
   - [ ] Display QR code in separate view
   - [ ] Export config to clipboard
   - [ ] Scan QR code with camera
   - [ ] Parse scanned data correctly
   - [ ] Handle invalid QR codes

3. **Camera Permissions:**
   - [ ] Request permission on first scan
   - [ ] Handle permission granted
   - [ ] Handle permission denied
   - [ ] Handle permanently denied (settings redirect)

4. **Export to GitHub:**
   - [ ] Select GitHub destination
   - [ ] Check for credentials
   - [ ] Check settings permission
   - [ ] Upload tasks.json successfully
   - [ ] Handle upload errors
   - [ ] Update existing file

5. **Import from GitHub:**
   - [ ] Switch to GitHub tab
   - [ ] Check for credentials
   - [ ] Check settings permission
   - [ ] Download tasks.json successfully
   - [ ] Handle download errors
   - [ ] Parse and display data

6. **Settings Integration:**
   - [ ] Toggle GitHub export setting
   - [ ] Persist setting to database
   - [ ] Enforce setting in export/import
   - [ ] Show confirmation dialogs

7. **Navigation:**
   - [ ] Navigate to config form from sidebar
   - [ ] Navigate to QR display
   - [ ] Navigate to error page
   - [ ] Navigate to settings from dialogs

8. **Error Scenarios:**
   - [ ] Invalid credentials
   - [ ] Network failure
   - [ ] Repository not found
   - [ ] File not found
   - [ ] Invalid JSON format
   - [ ] Permission denied

## UI/UX Design

### GitHub Configuration Form Page

**Location:** `lib/pages/github/github_config_page.dart`

**Layout:**
```
┌─────────────────────────────────────┐
│ ← GitHub Configuration          ⓘ  │ <- AppBar with info button
├─────────────────────────────────────┤
│                                     │
│  Token: ________________________    │ <- Multi-line TextField
│         ________________________    │
│                                     │
│  Owner: ________________________    │ <- TextField
│                                     │
│  Repository: ___________________    │ <- TextField
│                                     │
│  Path Prefix: __________________    │ <- TextField (default: /)
│                                     │
│  Branch: _______________________    │ <- TextField (default: master)
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│  ┌─────────┐         ┌──────────┐  │
│  │ 📱 QR   │         │ 📋 Copy  │  │ <- FABs
│  └─────────┘         └──────────┘  │
└─────────────────────────────────────┘
```

**Features:**
- Multi-line text input with wrapping
- Validation on save
- Info button shows QR scanning instructions
- Left FAB: Generate and display QR code
- Right FAB: Copy config JSON to clipboard

### QR Code Display Page

**Location:** `lib/pages/github/github_qr_display_page.dart`

**Layout:**
```
┌─────────────────────────────────────┐
│ ← GitHub Configuration QR           │
├─────────────────────────────────────┤
│                                     │
│                                     │
│         ┌─────────────────┐         │
│         │                 │         │
│         │                 │         │
│         │   QR CODE HERE  │         │
│         │                 │         │
│         │                 │         │
│         └─────────────────┘         │
│                                     │
│  Scan this QR code with another     │
│  device to import GitHub settings   │
│                                     │
│                                     │
│  ┌──────────────────────────────┐  │
│  │        Close                 │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### QR Scanning Instructions Dialog

**Content:**
```
Camera Permission Required

To quickly import GitHub configuration from 
another device:

1. Generate a QR code on your computer
2. Grant camera permission on this device
3. Scan the QR code to auto-fill credentials

This saves you from manually copying and 
pasting configuration between devices.

┌──────────────┐  ┌──────────────────┐
│   Cancel     │  │  Grant & Scan    │
└──────────────┘  └──────────────────┘
```

### Export Dialog Enhancement

**Current:** Simple file picker
**Enhanced:** Destination selection

```
Export Tasks

Where would you like to export?

  ○ Local Storage (Default)
  ○ GitHub Repository

Format: v2 (JSON)

┌──────────────┐  ┌──────────────────┐
│   Cancel     │  │     Export       │
└──────────────┘  └──────────────────┘
```

### Import Page Enhancement

**Current:** Single file picker
**Enhanced:** Tabbed interface

```
┌─────────────────────────────────────┐
│ ← Import                            │
├─────────────────────────────────────┤
│  Local  │  GitHub                   │ <- Tabs
├─────────────────────────────────────┤
│                                     │
│  [GitHub tab content]               │
│                                     │
│  Repository: owner/repo             │
│  Branch: master                     │
│  Path: /tasks.json                  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │    Load from GitHub          │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Sidebar Controls Enhancement

**Current Structure:**
```
Controls
├── Grid Views
│   ├── Task Grid
│   ├── Project Grid
│   └── Label Grid
└── Export & Import
    ├── Export
    └── Import
```

**Enhanced Structure:**
```
Controls
├── Grid Views
│   ├── Task Grid
│   ├── Project Grid
│   └── Label Grid
├── Export & Import
│   ├── Export
│   └── Import
└── GitHub Configuration  <- New section
    └── Setup GitHub Backup
```

## Routing Configuration

**Location:** `lib/router/router.dart`

**New Routes:**
```dart
GoRoute(
  path: 'github_config',
  builder: (BuildContext context, GoRouterState state) {
    return GitHubConfigPage();
  },
),
GoRoute(
  path: 'github_qr_display',
  builder: (BuildContext context, GoRouterState state) {
    final config = state.extra as GitHubConfig;
    return GitHubQRDisplayPage(config: config);
  },
),
GoRoute(
  path: 'github_error',
  builder: (BuildContext context, GoRouterState state) {
    final params = state.extra as Map<String, dynamic>;
    return GitHubErrorPage(
      errorMessage: params['errorMessage'],
      operation: params['operation'],
      timestamp: params['timestamp'],
    );
  },
),
```

## Dependencies

**Add to pubspec.yaml:**
```yaml
dependencies:
  github: ^9.24.0
  barcode_scan2: ^4.3.3
  barcode_widget: ^2.0.4
  clipboard: ^0.1.3
  
  # Existing dependencies
  permission_handler: ^11.3.1
  shared_preferences: ^2.2.3
```

**Installation Command:**
```bash
fvm flutter pub add github barcode_scan2 barcode_widget clipboard
```

## Implementation Notes

### FVM Usage
All Flutter and Dart commands must be prefixed with `fvm`:
- `fvm flutter pub add <package>`
- `fvm flutter pub get`
- `fvm dart format lib/`
- `fvm flutter run`

### No Internationalization
All UI text should be hardcoded in English:
- Do NOT use `AppLocalizations.of(context)`
- Do NOT add keys to l10n files
- Use clear, concise English strings directly

### Permission Handler Integration
All permission requests must go through the existing `PermissionHandlerService`:
- Use `PermissionHandlerService.instance.checkAndRequestCameraPermission(context)`
- Follow the existing pattern for permission dialogs
- Add camera permission methods to the existing class

### State Management Pattern
Follow the CommentCubit pattern:
- Simple state emission
- Load from shared_preferences on init
- Persist on update
- Provide helper methods

### Error Handling
- Always catch and log errors
- Display user-friendly error messages
- Provide navigation back to previous screen
- Include error details for debugging

## Security Considerations

1. **Token Storage:**
   - Stored in shared_preferences (not encrypted)
   - User should use tokens with minimal permissions
   - Consider adding warning about token security

2. **QR Code Security:**
   - QR codes contain sensitive token
   - Warn users not to share QR codes publicly
   - QR codes should be temporary/one-time use

3. **GitHub Permissions:**
   - Token needs repo read/write access
   - Recommend using fine-grained tokens
   - Limit token scope to specific repository

## Performance Considerations

1. **GitHub API:**
   - Rate limiting: 5000 requests/hour for authenticated users
   - File size limit: 100MB (tasks.json should be much smaller)
   - Network timeout: 30 seconds

2. **QR Code Generation:**
   - Generate on-demand, not cached
   - Size: 300x300 pixels (adequate for JSON data)

3. **Shared Preferences:**
   - Minimal overhead for config storage
   - Load once on app start

## Future Enhancements (Out of Scope)

- Automatic sync on app start/close
- Conflict resolution for concurrent edits
- Multiple repository support
- Encrypted token storage
- OAuth authentication flow
- Sync history and versioning
- Internationalization support
