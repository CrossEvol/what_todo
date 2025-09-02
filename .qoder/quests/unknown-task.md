# Flutter Auto-Update Feature Design Document

## Overview

This document outlines the design for implementing automatic update functionality in the WhatTodo Flutter application. The feature will enable over-the-air (OTA) updates by detecting new releases from GitHub, downloading APK files, and guiding users through the installation process with comprehensive UI feedback.

### Core Objectives
- Implement automatic version checking with daily silent checks
- Provide intuitive update notifications using badges and dialog interfaces
- Display download progress in both notification bar and main UI
- Enable seamless APK installation with proper permission handling
- Integrate with existing BLoC architecture and logging system

### Target Platforms
- Android (primary focus)
- Future expansion to iOS and desktop platforms

## Architecture

### Integration with Existing System
The auto-update feature will integrate seamlessly with the current BLoC-based architecture:

```mermaid
graph TD
    A[UpdateBloc] --> B[UpdateRepository]
    B --> C[UpdateService]
    C --> D[GitHub API]
    C --> E[DownloadManager]
    A --> F[UI Components]
    F --> G[SideDrawer Badge]
    F --> H[Update Dialog]
    F --> I[Progress Components]
    E --> J[NotificationService]
    E --> K[FileManager]
    
    style A fill:#e1f5fe
    style F fill:#f3e5f5
    style C fill:#e8f5e8
```

### Component Architecture

#### Core Components Overview
```mermaid
classDiagram
    class UpdateBloc {
        +UpdateRepository repository
        +checkForUpdates()
        +downloadUpdate()
        +installUpdate()
        +scheduleCheck()
    }
    
    class UpdateRepository {
        +UpdateService service
        +SharedPrefsUtil prefs
        +getLatestVersion()
        +downloadApk()
        +saveLastCheckTime()
    }
    
    class UpdateService {
        +Dio dio
        +PackageInfo package
        +checkGitHubRelease()
        +compareVersions()
        +downloadFile()
    }
    
    class DownloadManager {
        +FlutterDownloader downloader
        +NotificationService notifications
        +startDownload()
        +trackProgress()
        +handleCompletion()
    }
    
    UpdateBloc --> UpdateRepository
    UpdateRepository --> UpdateService
    UpdateRepository --> DownloadManager
    DownloadManager --> NotificationService
```

## Technology Stack & Dependencies

### New Dependencies
The following packages will be added using FVM commands:

| Package | Purpose | Version Strategy |
|---------|---------|------------------|
| dio | HTTP client with interceptors | Auto-resolved |
| package_info_plus | Current app version | Auto-resolved |
| pub_semver | Version comparison | Auto-resolved |
| flutter_downloader | File download management | Auto-resolved |
| open_filex | APK installation | Auto-resolved |
| flutter_local_notifications | Progress notifications | Auto-resolved |
| badges | Visual update indicators | Auto-resolved |

### Dependency Installation Commands
```bash
fvm flutter pub add dio
fvm flutter pub add package_info_plus
fvm flutter pub add pub_semver
fvm flutter pub add flutter_downloader
fvm flutter pub add open_filex
fvm flutter pub add flutter_local_notifications
fvm flutter pub add badges
```

### Network Configuration
```mermaid
graph LR
    A[Dio Instance] --> B[Request Interceptor]
    A --> C[Response Interceptor]
    A --> D[Error Interceptor]
    B --> E[Logger Integration]
    C --> E
    D --> E
    E --> F[Existing Logger Util]
```

## Data Models & State Management

### Update Models
```dart
// Version Information Model
class VersionInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime publishedAt;
  final int fileSize;
}

// Update State Model
abstract class UpdateState extends Equatable {
  const UpdateState();
}

class UpdateInitial extends UpdateState {}
class UpdateChecking extends UpdateState {}
class UpdateAvailable extends UpdateState {
  final VersionInfo versionInfo;
}
class UpdateDownloading extends UpdateState {
  final double progress;
  final String fileName;
}
class UpdateDownloaded extends UpdateState {
  final String filePath;
}
class UpdateError extends UpdateState {
  final String message;
}
```

### BLoC Event System
```mermaid
stateDiagram-v2
    [*] --> UpdateInitial
    UpdateInitial --> UpdateChecking: CheckForUpdatesEvent
    UpdateChecking --> UpdateAvailable: Update Found
    UpdateChecking --> UpdateInitial: No Update
    UpdateAvailable --> UpdateDownloading: StartDownloadEvent
    UpdateDownloading --> UpdateDownloaded: Download Complete
    UpdateDownloaded --> UpdateInitial: InstallUpdateEvent
    UpdateChecking --> UpdateError: Error Occurred
    UpdateDownloading --> UpdateError: Download Failed
```

## API Integration Layer

### GitHub Release API Integration
```mermaid
sequenceDiagram
    participant App as WhatTodo App
    participant API as GitHub API
    participant Storage as Local Storage
    
    App->>Storage: Check last check time
    Storage->>App: Return timestamp
    
    alt Daily check needed
        App->>API: GET /repos/CrossEvol/what_todo/releases/latest
        API->>App: Release information
        App->>App: Compare versions
        
        alt New version available
            App->>Storage: Store update available flag
            App->>App: Show badge notification
        end
    end
```

### Network Request Structure
```dart
class UpdateService {
  final Dio _dio;
  final ILogger _logger;
  
  Future<VersionInfo?> checkLatestVersion() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/CrossEvol/what_todo/releases/latest'
      );
      return VersionInfo.fromJson(response.data);
    } catch (e) {
      _logger.error('Update check failed: $e');
      return null;
    }
  }
}
```

## UI Components Design

### SideDrawer Integration
```mermaid
graph TD
    A[SideDrawer] --> B[Existing Menu Items]
    A --> C[Update Section]
    C --> D[Update Menu Item]
    D --> E[Badges Component]
    E --> F{Update Available?}
    F -->|Yes| G[Red Dot Badge]
    F -->|No| H[No Badge]
    D --> I[Update Dialog Trigger]
    
    style C fill:#fff3e0
    style G fill:#ffebee
```

### Update Dialog Components
```mermaid
graph TD
    A[Update Dialog] --> B[Version Information]
    A --> C[Release Notes]
    A --> D[Action Buttons]
    B --> E[Current Version]
    B --> F[New Version]
    B --> G[File Size]
    D --> H[Update Now]
    D --> I[Later]
    D --> J[Skip Version]
    
    style A fill:#e8f5e8
    style H fill:#c8e6c9
```

### Progress Display Components
```mermaid
graph TD
    A[Progress System] --> B[Home Page Progress Bar]
    A --> C[Notification Progress]
    B --> D[Linear Progress Indicator]
    B --> E[Progress Percentage]
    B --> F[Download Speed]
    C --> G[Notification Builder]
    C --> H[Progress Updates]
    
    style B fill:#e3f2fd
    style C fill:#fff3e0
```

## Business Logic Layer

### Update Check Scheduling
```mermaid
flowchart TD
    A[App Launch] --> B{Last Check > 24h?}
    B -->|Yes| C[Silent Update Check]
    B -->|No| D[Skip Check]
    C --> E{Update Available?}
    E -->|Yes| F[Set Badge Flag]
    E -->|No| G[Update Check Time]
    F --> H[Show Badge in SideDrawer]
    G --> I[Continue Normal Flow]
    H --> I
    D --> I
```

### Version Comparison Logic
```dart
class VersionComparator {
  static bool isNewerVersion(String current, String latest) {
    final currentVersion = Version.parse(current);
    final latestVersion = Version.parse(latest);
    return latestVersion > currentVersion;
  }
}
```

### Download Management
```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Downloading: Start Download
    Downloading --> Paused: Network Issues
    Downloading --> Completed: Success
    Downloading --> Failed: Error
    Paused --> Downloading: Retry
    Failed --> Idle: Reset
    Completed --> Installing: User Confirms
    Installing --> [*]: Installation Complete
```

## Permissions & Platform Configuration

### Android Manifest Configuration
```xml
<!-- Required Permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- FileProvider Configuration -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

### Provider Paths Configuration
```xml
<!-- android/app/src/main/res/xml/provider_paths.xml -->
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
</paths>
```

## Security & Privacy

### Security Measures
```mermaid
graph TD
    A[Security Layer] --> B[HTTPS Only]
    A --> C[Source Verification]
    A --> D[Permission Validation]
    A --> E[Error Handling]
    
    B --> F[TLS Certificate Validation]
    C --> G[GitHub Domain Check]
    D --> H[Runtime Permission Check]
    E --> I[Graceful Degradation]
    
    style A fill:#ffebee
    style B fill:#e8f5e8
```

### Privacy Considerations
- No personal data collection for update checks
- Local storage of update preferences only
- Transparent permission requests with clear explanations
- User control over update timing and installation

## Testing Strategy

### Unit Testing Scope
```mermaid
graph TD
    A[Unit Tests] --> B[Version Comparison]
    A --> C[Update State Logic]
    A --> D[Download Progress]
    A --> E[Permission Handling]
    
    B --> F[SemVer Validation]
    C --> G[BLoC State Transitions]
    D --> H[Progress Calculations]
    E --> I[Permission Status]
    
    style A fill:#e1f5fe
```

### Integration Testing
- Badge visibility and interaction
- Download progress synchronization
- Notification system integration
- File system access validation

### Test Data Structure
```dart
class UpdateTestData {
  static const mockVersionResponse = {
    'tag_name': 'v2.0.0',
    'name': 'Version 2.0.0',
    'body': 'Release notes here',
    'assets': [
      {
        'name': 'app-release.apk',
        'browser_download_url': 'https://github.com/...',
        'size': 25000000
      }
    ]
  };
}
```

## Error Handling & User Experience

### Error Scenarios
```mermaid
flowchart TD
    A[Error Types] --> B[Network Errors]
    A --> C[Permission Denied]
    A --> D[Download Failures]
    A --> E[Installation Issues]
    
    B --> F[Retry with Backoff]
    C --> G[Permission Dialog]
    D --> H[Resume/Restart Options]
    E --> I[Manual Installation Guide]
    
    style A fill:#ffebee
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style I fill:#fff3e0
```

### User Feedback System
- Clear error messages with actionable solutions
- Progress indicators with time estimates
- Success confirmations and next steps
- Fallback options for failed operations

## Performance & Optimization

### Resource Management
```mermaid
graph TD
    A[Performance Optimization] --> B[Memory Management]
    A --> C[Network Efficiency]
    A --> D[Storage Optimization]
    
    B --> E[Stream Controllers]
    B --> F[Dispose Patterns]
    C --> G[Request Caching]
    C --> H[Retry Logic]
    D --> I[Temp File Cleanup]
    D --> J[Compression Support]
    
    style A fill:#e8f5e8
```

### Optimization Strategies
- Lazy loading of update components
- Efficient progress reporting (throttled updates)
- Background download with minimal UI impact
- Cleanup of temporary files after installation

## Future Enhancements

### Planned Features
```mermaid
mindmap
  root((Future Features))
    iOS Support
      App Store Guidelines
      TestFlight Integration
    Desktop Updates
      Windows MSIX
      macOS DMG
      Linux AppImage
    Advanced Features
      Delta Updates
      A/B Testing
      Rollback Capability
    Analytics
      Update Success Rates
      User Adoption Metrics
```

### Extensibility Points
- Plugin architecture for different update sources
- Customizable UI themes for update dialogs
- Integration with crash reporting systems
- Support for staged rollouts and feature flags