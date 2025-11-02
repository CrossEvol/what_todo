# Design Document

## Overview

The Task Resource Management feature extends the existing Flutter task management application to support image attachments. The design integrates seamlessly with the current Drift database architecture, BLoC pattern, and Go Router navigation system. Resources are stored in the application's internal storage using path_provider and managed through a dedicated Resource Management interface.

## Architecture

### Database Layer
The existing Drift database schema is extended with a new `Resource` table that maintains referential integrity with the `Task` table through foreign key constraints with cascade deletion.

**Resource Table Schema:**
```sql
CREATE TABLE resource (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT NOT NULL,
  task_id INTEGER REFERENCES task(id) ON DELETE CASCADE,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Note:** The `task_id` field is nullable to support the workflow where resources are created before task creation (e.g., when sharing media files to create new tasks).

### Data Flow Architecture
The feature follows the established data flow pattern:
```
Database (Drift) → DAO Layer → BLoC Layer → UI Layer
```

## Components and Interfaces

### 1. Data Models

**ResourceModel** (`lib/models/resource.dart`)
```dart
class ResourceModel {
  final int id;  // Auto-increment database ID
  final String path;
  final int? taskId;  // Nullable to support pre-task resource creation
  
  ResourceModel({required this.id, required this.path, this.taskId});
}
```

**Enhanced Task Model** (`lib/pages/tasks/models/task.dart`)
- Add `List<ResourceModel> resources = []` property
- Update constructors and serialization methods to handle resources

### 2. Database Access Layer

**ResourceDAO** (`lib/dao/resource_db.dart`)
- `Future<List<ResourceModel>> getResourcesByTaskId(int taskId)`
- `Future<List<ResourceModel>> getUnassignedResources()` // Resources with null taskId
- `Future<int> insertResource(ResourceModel resource)`
- `Future<bool> updateResourceTaskId(int resourceId, int taskId)` // Associate resource with task
- `Future<bool> deleteResource(int resourceId)`
- `Future<bool> deleteResourcesByTaskId(int taskId)`

**Enhanced TaskDB** (`lib/pages/tasks/task_db.dart`)
- Modify `_bindData()` method to include resource loading
- Update all task query methods to join with Resource table
- Ensure resources are loaded whenever tasks are retrieved

### 3. BLoC Layer

**ResourceBloc** (`lib/bloc/resource/resource_bloc.dart`)

**Events:**
```dart
abstract class ResourceEvent extends Equatable {}

class LoadResourcesEvent extends ResourceEvent {
  final int taskId;
  LoadResourcesEvent(this.taskId);
}

class AddResourceEvent extends ResourceEvent {
  final int taskId;
  final String imagePath;
  AddResourceEvent(this.taskId, this.imagePath);
}

class RemoveResourceEvent extends ResourceEvent {
  final int resourceId;
  final String filePath;
  RemoveResourceEvent(this.resourceId, this.filePath);
}
```

**States:**
```dart
abstract class ResourceState extends Equatable {}

class ResourceInitial extends ResourceState {}
class ResourceLoading extends ResourceState {}
class ResourceLoaded extends ResourceState {
  final List<ResourceModel> resources;
  ResourceLoaded(this.resources);
}
class ResourceError extends ResourceState {
  final String message;
  ResourceError(this.message);
}
```

### 4. UI Components

**ResourceManagePage** (`lib/pages/resource/resource_manage_page.dart`)
- ListView displaying resources with swipe-to-delete functionality
- FloatingActionButton for adding new resources
- Image picker integration for gallery selection
- Confirmation dialogs for deletion

**Resource Display Widgets:**
- `ResourceCountIndicator`: Link icon + count for home page task rows
- `ResourceThumbnailRow`: Horizontal scrollable thumbnails for edit page
- `ResourceDetailList`: Vertical list for detail page

## Data Models

### Resource Storage Strategy
- **Internal Storage**: Use `path_provider` to get application documents directory
- **File Organization**: Store images in `{app_documents}/resources/` directory
- **File Naming**: Use database auto-increment ID for consistent file naming
- **Supported Formats**: Initially support common image formats (jpg, png, gif, webp)

### Resource Lifecycle
1. **Addition**: Copy selected image from gallery to internal storage
2. **Association**: Create database record linking file path to task
3. **Display**: Load and display images from internal storage paths
4. **Deletion**: Remove both database record and physical file

## Error Handling

### File Operations
- Handle storage permission issues gracefully
- Manage insufficient storage space scenarios
- Provide fallback for corrupted or missing files
- Implement retry mechanisms for failed file operations

### Database Operations
- Handle foreign key constraint violations
- Manage concurrent access to resources
- Implement transaction rollback for failed operations
- Provide meaningful error messages to users

### UI Error States
- Display loading indicators during file operations
- Show error messages for failed operations
- Provide retry options for recoverable errors
- Graceful degradation when resources are unavailable



## Implementation Considerations

### Performance Optimizations
- Implement image thumbnail caching for faster display
- Use lazy loading for resource lists
- Optimize database queries with proper indexing
- Implement image compression for storage efficiency

### User Experience
- Provide visual feedback during file operations
- Implement smooth animations for resource management
- Ensure consistent UI patterns with existing application
- Support accessibility features for resource interactions

### Security and Privacy
- Validate file types before storage
- Implement file size limits to prevent abuse
- Ensure proper cleanup of temporary files
- Respect user privacy for image handling

### Scalability
- Design for potential future resource types (documents, audio)
- Implement efficient pagination for large resource lists
- Consider cloud storage integration for future versions
- Plan for resource synchronization across devices