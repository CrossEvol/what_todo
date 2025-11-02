# Implementation Plan

- [x] 1. Create Resource model and verify database schema
  - Create ResourceModel class in lib/models/resource.dart with id, path, and taskId properties
  - Verify Resource table exists in database with proper foreign key constraints
  - _Requirements: 1.3, 4.4_

- [x] 2. Implement Resource DAO layer
  use fvm before flutter or dart commands.
  - [x] 2.1 Create resource_db.dart in lib/dao/ directory
    - Implement getResourcesByTaskId method to fetch resources for a specific task
    - Implement insertResource method to add new resource records
    - Implement deleteResource method to remove resource by ID
    - _Requirements: 4.3, 1.1_

  - [x] 2.2 Update TaskDB to include resource loading
    - Modify _bindData method to join with Resource table and load associated resources
    - Update Task model to include List<ResourceModel> resources property
    - Ensure all task queries automatically load related resources
    - _Requirements: 4.1, 4.2_

- [x] 3. Create Resource BLoC for state management
  - [x] 3.1 Implement ResourceBloc with events and states
    - Create LoadResourcesEvent, AddResourceEvent, and RemoveResourceEvent
    - Implement ResourceLoading, ResourceLoaded, and ResourceError states
    - Handle resource loading, adding, and removal operations
    - _Requirements: 4.3, 3.3_

  - [x] 3.2 Integrate file operations with BLoC
    - Implement image copying from gallery to internal storage using path_provider
    - Handle file deletion when resources are removed
    - Manage file path generation and storage organization
    - _Requirements: 1.1, 3.4_

- [x] 4. Update Task model and data flow
  - [x] 4.1 Extend Task model with resources property
    - Add List<ResourceModel> resources property to Task class
    - Update Task constructors, copyWith, and serialization methods
    - Ensure resources are properly handled in task operations
    - _Requirements: 4.1_

  - [x] 4.2 Update task BLoC to handle resource data
    - Ensure TaskBloc properly propagates resource data through task operations
    - Update task loading, creation, and update operations to include resources
    - _Requirements: 4.5_

- [ ] 5. Create Resource Management Page
  - [ ] 5.1 Implement ResourceManagePage UI
    - Create page in lib/pages/resource/ directory with ListView for resource display
    - Implement swipe-to-delete functionality with confirmation dialogs
    - Add FloatingActionButton for adding new resources from gallery
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 5.2 Add navigation route for resource management
    - Add /resource/edit route to router configuration
    - Implement navigation from EditTaskScreen to ResourceManagePage
    - Pass taskId parameter for resource loading
    - _Requirements: 5.2, 5.4_

- [ ] 6. Update existing UI components for resource display
  - [ ] 6.1 Update home page task rows
    - Modify TaskRow and TaskCompletedRow components to show resource count indicator
    - Add link icon with resource count for tasks that have attached resources
    - Ensure minimal space usage in compact home view
    - _Requirements: 2.1_

  - [ ] 6.2 Update EditTaskScreen with resource preview
    - Add resource thumbnail row as bottom section of edit screen
    - Implement horizontal scrollable thumbnail display with wrap functionality
    - Add tap navigation to ResourceManagePage
    - _Requirements: 2.2, 2.5, 5.1_

  - [ ] 6.3 Update TaskDetailPage with resource display
    - Add resource display card in task detail view
    - Implement vertical list of resources within card component
    - Display full-size resource images in detail context
    - _Requirements: 2.3_

- [ ] 7. Implement image picker and file management utilities
  - Create utility functions for image selection from device gallery
  - Implement file copying to internal storage with proper error handling
  - Add file cleanup functionality for resource deletion
  - Handle storage permissions and error scenarios gracefully
  - _Requirements: 1.1, 3.4_