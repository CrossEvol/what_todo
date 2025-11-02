# Requirements Document

## Introduction

This feature adds image resource management capabilities to tasks in the Flutter task management application. Users will be able to attach, view, and manage image resources associated with their tasks through a dedicated resource management interface.

## Glossary

- **Resource**: An image file associated with a task, stored in the application's internal storage
- **Task Management System**: The existing Flutter application for managing tasks
- **Resource Management Page**: A dedicated page for managing resources associated with a specific task
- **Internal Storage**: Application-specific storage directory managed by path_provider
- **Task Row**: UI component displaying task information in list views
- **Edit Task Screen**: Screen for modifying task properties
- **Detail Task Screen**: Screen for viewing complete task information

## Requirements

### Requirement 1

**User Story:** As a user, I want to attach image resources to my tasks, so that I can associate visual information with my work items.

#### Acceptance Criteria

1. WHEN a user selects images from their device gallery, THE Task Management System SHALL copy the selected images to internal storage
2. THE Task Management System SHALL create Resource records with unique IDs, file paths, and optional task associations
3. THE Task Management System SHALL store Resource metadata in the database with ID, PATH, TASK_ID (nullable), and createTime fields
4. WHEN a Resource is created, THE Task Management System SHALL generate a unique identifier and timestamp automatically
5. THE Task Management System SHALL support only image file formats for Resource attachments

### Requirement 6

**User Story:** As a user, I want to create tasks from shared media files, so that I can quickly convert external content into actionable tasks.

#### Acceptance Criteria

1. WHEN a user shares media files to create a new task, THE Task Management System SHALL create Resource records without task associations initially
2. WHEN a user creates a task in AddTaskPage with pre-existing resources, THE Task Management System SHALL associate the resources with the newly created task
3. THE Task Management System SHALL support creating resources with null taskId values for temporary storage
4. WHEN a task is created with associated resources, THE Task Management System SHALL update the Resource records to link them to the task
5. THE Task Management System SHALL handle the workflow of resource creation before task creation seamlessly

### Requirement 2

**User Story:** As a user, I want to view attached resources in different contexts, so that I can quickly access visual information related to my tasks.

#### Acceptance Criteria

1. WHEN viewing tasks in the home list, THE Task Management System SHALL display a link icon with resource count for tasks that have attached resources
2. WHEN viewing a task in edit mode, THE Task Management System SHALL display thumbnail previews of attached resources in a horizontal scrollable row
3. WHEN viewing task details, THE Task Management System SHALL display all attached resources in a vertical list within a card component
4. THE Task Management System SHALL wrap thumbnail displays when content exceeds available width
5. WHEN a user taps on resource displays in edit mode, THE Task Management System SHALL navigate to the Resource Management Page

### Requirement 3

**User Story:** As a user, I want to manage attached resources through a dedicated interface, so that I can add or remove images as needed.

#### Acceptance Criteria

1. WHEN a user navigates to the Resource Management Page, THE Task Management System SHALL load and display all resources associated with the specific task
2. WHEN a user taps the floating action button, THE Task Management System SHALL open the device gallery for image selection
3. WHEN a user swipes to delete a resource, THE Task Management System SHALL show a confirmation dialog before removal
4. WHEN a user confirms resource deletion, THE Task Management System SHALL remove the file from internal storage and delete the database record
5. THE Task Management System SHALL update the resource list immediately after additions or deletions

### Requirement 4

**User Story:** As a developer, I want proper data layer integration, so that resource management is consistent with the existing application architecture.

#### Acceptance Criteria

1. THE Task Management System SHALL extend the Task model to include a List<Resource> property
2. WHEN querying tasks from the database, THE Task Management System SHALL automatically load associated resources
3. THE Task Management System SHALL implement Resource DAO operations for create, read, and delete operations
4. THE Task Management System SHALL maintain referential integrity between tasks and resources
5. THE Task Management System SHALL propagate resource data through the task_db -> task_bloc -> task_page data flow

### Requirement 5

**User Story:** As a user, I want resource management to integrate seamlessly with existing task workflows, so that the feature feels natural within the application.

#### Acceptance Criteria

1. THE Task Management System SHALL add resource management navigation to the Edit Task Screen as the bottom row
2. THE Task Management System SHALL implement the /resource/edit route for resource management navigation
3. THE Task Management System SHALL implement Resource BLoC with load, add, and remove events
4. WHEN the Edit Task Screen loads, THE Task Management System SHALL trigger resource loading for the current task
5. THE Task Management System SHALL maintain consistent UI patterns with existing application design