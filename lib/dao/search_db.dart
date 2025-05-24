import 'package:drift/drift.dart';
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart' as lb;
import 'package:flutter_app/pages/tasks/models/task.dart';

/// Class representing search results with pagination information
class SearchResult {
  final List<Task> tasks;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  SearchResult({
    required this.tasks,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

/// Class to handle all search operations in the application
class SearchDB {
  // Singleton instance
  static final SearchDB _searchDb = SearchDB._internal(AppDatabase());

  // Database instance
  AppDatabase _db;

  // Private internal constructor to make it singleton
  SearchDB._internal(this._db);

  // Static method to get instance
  static SearchDB get() {
    return _searchDb;
  }

  /// Search for tasks based on criteria
  Future<SearchResult> searchTasks({
    required String keyword,
    required bool searchInTitle,
    required bool searchInComment,
    FilteredField? filteredField,
    Order? order,
    required int page,
    required int itemsPerPage,
  }) async {
    // Query to select tasks with their project and label information
    var query = _db.select(_db.task).join([
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
    ]);

    // Apply filters for keyword search
    if (keyword.isNotEmpty) {
      var conditions = <Expression<bool>>[];

      if (searchInTitle) {
        conditions.add(_db.task.title.like('%$keyword%'));
      }

      if (searchInComment) {
        conditions.add(_db.task.comment.like('%$keyword%'));
      }

      if (conditions.isNotEmpty) {
        // Combine conditions with OR if both are enabled
        Expression<bool> whereCondition = conditions.fold(
          conditions.first,
          (previousValue, element) => previousValue | element,
        );

        query.where(whereCondition);
      }
    }

    // Apply sorting
    if (filteredField != null) {
      OrderingTerm orderingTerm;

      switch (filteredField) {
        case FilteredField.id:
          orderingTerm = OrderingTerm(
            expression: _db.task.id,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
        case FilteredField.title:
          orderingTerm = OrderingTerm(
            expression: _db.task.title,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
        case FilteredField.project:
          orderingTerm = OrderingTerm(
            expression: _db.project.name,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
        case FilteredField.dueDate:
          orderingTerm = OrderingTerm(
            expression: _db.task.dueDate,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
        case FilteredField.status:
          orderingTerm = OrderingTerm(
            expression: _db.task.status,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
        case FilteredField.priority:
          orderingTerm = OrderingTerm(
            expression: _db.task.priority,
            mode: order == Order.asc ? OrderingMode.asc : OrderingMode.desc,
          );
          break;
      }

      query.orderBy([orderingTerm]);
    } else {
      // Default order by order and then due date if no field specified
      query.orderBy([
        OrderingTerm.desc(_db.task.order),
        OrderingTerm.desc(_db.task.dueDate),
      ]);
    }

    // Fetch all results first
    var results = await query.get();

    // Process results to eliminate duplicates (due to join with labels)
    Map<int, Map<String, dynamic>> taskDataMap = {};
    Map<int, List<lb.Label>> taskLabels = {};

    // Process the results into Task objects
    for (var row in results) {
      final taskRow = row.readTable(_db.task);
      final projectRow = row.readTable(_db.project);
      final labelRow = row.readTableOrNull(_db.label);

      final taskId = taskRow.id;

      // Initialize the task data if it doesn't exist
      if (!taskDataMap.containsKey(taskId)) {
        taskDataMap[taskId] = {
          Task.dbId: taskId,
          Task.dbTitle: taskRow.title,
          Task.dbComment: taskRow.comment ?? "",
          Task.dbDueDate: taskRow.dueDate?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
          Task.dbPriority: taskRow.priority ?? PriorityStatus.PRIORITY_4.index,
          Task.dbStatus: taskRow.status,
          Task.dbProjectID: taskRow.projectId,
          Task.dbOrder: taskRow.order,
          'projectName': projectRow.name,
          'projectColor': projectRow.colorCode,
        };

        // Initialize empty label list
        taskLabels[taskId] = [];
      }

      // Add label if it exists and is not already in the list
      if (labelRow != null) {
        final label = lb.Label.create(
          labelRow.name,
          labelRow.colorCode,
          labelRow.colorName,
        );
        label.id = labelRow.id;

        // Check if this label is already in the list
        if (!taskLabels[taskId]!.any((l) => l.id == label.id)) {
          taskLabels[taskId]!.add(label);
        }
      }
    }

    // Create Task objects from the collected data
    List<Task> tasks = [];
    taskDataMap.forEach((id, data) {
      Task task = Task.fromMap(data);
      task.projectName = data['projectName'];
      task.projectColor = data['projectColor'];
      task.labelList = taskLabels[id] ?? [];
      tasks.add(task);
    });

    // Calculate pagination info
    final totalItems = tasks.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    final safetyPage = page > totalPages && totalPages > 0 ? 1 : page;

    // Apply pagination
    final startIndex = (safetyPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    final List<Task> pagedTasks = startIndex < tasks.length
        ? tasks.sublist(
            startIndex,
            endIndex > totalItems ? totalItems : endIndex,
          )
        : [];

    return SearchResult(
      tasks: pagedTasks,
      currentPage: safetyPage,
      totalPages: totalPages > 0 ? totalPages : 1,
      totalItems: totalItems,
    );
  }

  /// Count the number of tasks matching a search keyword
  Future<int> countSearchResults({
    required String keyword,
    required bool searchInTitle,
    required bool searchInComment,
  }) async {
    var query = _db.selectOnly(_db.task);
    query.addColumns([_db.task.id.count()]);

    // Apply filters for keyword search
    if (keyword.isNotEmpty) {
      var conditions = <Expression<bool>>[];

      if (searchInTitle) {
        conditions.add(_db.task.title.like('%$keyword%'));
      }

      if (searchInComment && _db.task.comment != null) {
        conditions.add(_db.task.comment.like('%$keyword%'));
      }

      if (conditions.isNotEmpty) {
        // Combine conditions with OR if both are enabled
        Expression<bool> whereCondition = conditions.fold(
          conditions.first,
          (previousValue, element) => previousValue | element,
        );

        query.where(whereCondition);
      }
    }

    var single = await query.getSingle();
    var count = single.read(_db.task.id.count()) ?? 0;
    return count;
  }

  /// Get tasks by searching for keyword and filter by status
  Future<List<Task>> getTasksByKeyword({
    required String keyword,
    required bool searchInTitle,
    required bool searchInComment,
    TaskStatus? status,
  }) async {
    // First, get task records from the database
    var query = _db.select(_db.task).join([
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    // Apply filters for keyword search
    if (keyword.isNotEmpty) {
      var conditions = <Expression<bool>>[];

      if (searchInTitle) {
        conditions.add(_db.task.title.like('%$keyword%'));
      }

      if (searchInComment) {
        conditions.add(_db.task.comment.like('%$keyword%'));
      }

      if (conditions.isNotEmpty) {
        // Combine conditions with OR if both are enabled
        Expression<bool> whereCondition = conditions.fold(
          conditions.first,
          (previousValue, element) => previousValue | element,
        );

        query.where(whereCondition);
      }
    }

    // Filter by status if specified
    if (status != null) {
      query.where(_db.task.status.equals(status.index));
    }

    // Order by priority and due date
    query.orderBy([
      OrderingTerm.desc(_db.task.priority),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var results = await query.get();

    // Now convert the database rows to Task objects
    List<Task> tasks = [];
    Map<int, Task> taskMap = {};

    for (var row in results) {
      final taskRow = row.readTable(_db.task);
      final projectRow = row.readTable(_db.project);

      // Create task from database row
      if (!taskMap.containsKey(taskRow.id)) {
        // Create a Map with the data from the database row
        final taskData = {
          Task.dbId: taskRow.id,
          Task.dbTitle: taskRow.title,
          Task.dbComment: taskRow.comment ?? "",
          Task.dbDueDate: taskRow.dueDate?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
          Task.dbPriority: taskRow.priority ?? PriorityStatus.PRIORITY_4.index,
          Task.dbStatus: taskRow.status,
          Task.dbProjectID: taskRow.projectId,
          Task.dbOrder: taskRow.order,
        };

        // Create Task object
        final task = Task.fromMap(taskData);
        task.projectName = projectRow.name;
        task.projectColor = projectRow.colorCode;

        // Get labels for this task (separate query)
        task.labelList = await _getLabelsForTask(taskRow.id);

        taskMap[taskRow.id] = task;
        tasks.add(task);
      }
    }

    return tasks;
  }

  /// Check if there are any tasks that match the search criteria
  Future<bool> hasSearchResults({
    required String keyword,
    required bool searchInTitle,
    required bool searchInComment,
  }) async {
    int count = await countSearchResults(
      keyword: keyword,
      searchInTitle: searchInTitle,
      searchInComment: searchInComment,
    );
    return count > 0;
  }

  /// Helper method to get labels for a task
  Future<List<lb.Label>> _getLabelsForTask(int taskId) async {
    var query = _db.select(_db.label).join([
      innerJoin(_db.taskLabel, _db.taskLabel.labelId.equalsExp(_db.label.id)),
    ]);

    query.where(_db.taskLabel.taskId.equals(taskId));

    var results = await query.get();
    List<lb.Label> labels = [];

    for (var row in results) {
      final labelRow = row.readTable(_db.label);
      final label = lb.Label.create(
        labelRow.name,
        labelRow.colorCode,
        labelRow.colorName,
      );
      label.id = labelRow.id;
      labels.add(label);
    }

    return labels;
  }
  
  /// Mark a task as done (completed)
  Future<bool> markTaskAsDone(int taskId) async {
    try {
      // Update the task status to COMPLETE (1)
      await (_db.update(_db.task)..where((t) => t.id.equals(taskId)))
          .write(const TaskCompanion(
        status: Value(1), // 1 = COMPLETE
      ));
      return true;
    } catch (e) {
      print('Error marking task as done: $e');
      return false;
    }
  }

  /// Mark a task as undone (not completed)
  Future<bool> markTaskAsUndone(int taskId) async {
    try {
      // Update the task status to NOT_COMPLETED (0)
      await (_db.update(_db.task)..where((t) => t.id.equals(taskId)))
          .write(const TaskCompanion(
        status: Value(0), // 0 = NOT_COMPLETED
      ));
      return true;
    } catch (e) {
      print('Error marking task as undone: $e');
      return false;
    }
  }

  /// Delete a task by its ID
  Future<bool> deleteTask(int taskId) async {
    try {
      // First delete any related task-label associations
      await (_db.delete(_db.taskLabel)..where((tl) => tl.taskId.equals(taskId))).go();
      
      // Then delete the task itself
      await (_db.delete(_db.task)..where((t) => t.id.equals(taskId))).go();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
}
