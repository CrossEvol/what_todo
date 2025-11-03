import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/projects/project.dart';

class ProjectDB {
  static final ProjectDB _projectDb = ProjectDB._internal(AppDatabase());

  AppDatabase _db;

  //private internal constructor to make it singleton
  ProjectDB._internal(this._db);

  static ProjectDB get() {
    return _projectDb;
  }

  Future<bool> isProjectExists(Project project) async {
    var result = await (_db.select(_db.project)
          ..where((tbl) => tbl.name.equals(project.name)))
        .get();
    if (result.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future insertProject(Project project) async {
    await _db.into(_db.project).insertOnConflictUpdate(
          ProjectCompanion(
            id: project.id != null ? Value(project.id ?? 0) : Value.absent(),
            name: Value(project.name),
            colorCode: Value(project.colorValue),
            colorName: Value(project.colorName),
          ),
        );
  }

  Future<Project> getProject(
      {required int id, bool isInboxVisible = true}) async {
    var query = _db.select(_db.project);
    if (!isInboxVisible) {
      query.where((tbl) => tbl.id.isNotIn([1]));
    }
    query.where((tbl) => tbl.id.equals(id));
    var result = await query.getSingle();
    return Project.fromMap(result.toJson());
  }

  Future<List<Project>> getProjects({bool isInboxVisible = true}) async {
    var query = _db.select(_db.project);
    if (!isInboxVisible) {
      query.where((tbl) => tbl.id.isNotIn([1]));
    }
    var result = await query.get();
    return result.map((item) => Project.fromMap(item.toJson())).toList();
  }

  Future<List<ProjectWithCount>> getProjectsWithCount() async {
    final query =
        _db.select(_db.project).addColumns([_db.task.projectId.count()]).join([
      leftOuterJoin(_db.task, _db.task.projectId.equalsExp(_db.project.id)),
    ])
          ..groupBy([_db.project.id]);

    final result = await query.get();

    return result.map((row) {
      final projectData = row.readTable(_db.project);
      final count = row.read(_db.task.projectId.count()) ?? 0;

      return ProjectWithCount.fromMap({
        ...projectData.toJson(),
        'count': count,
      });
    }).toList();
  }

  Future upsertProject(Project project) async {
    await _db.into(_db.project).insertOnConflictUpdate(
          ProjectCompanion(
            id: project.id != null ? Value(project.id!) : Value.absent(),
            name: Value(project.name),
            colorCode: Value(project.colorValue),
            colorName: Value(project.colorName),
          ),
        );
  }

  Future<bool> moveTasksToInbox(int projectID) async {
    final rows = await (_db.update(_db.task)
          ..where((tbl) => tbl.projectId.equals(projectID)))
        .write(TaskCompanion(projectId: const Value(1)));
    return rows >= 0;
  }

  Future<bool> deleteProject(int projectID) async {
    final affectedRows = await (_db.delete(_db.project)
          ..where((tbl) => tbl.id.equals(projectID)))
        .go();
    return affectedRows > 0;
  }

  Future<void> importProjects(Set<String> projectNames) async {
    for (var projectName in projectNames) {
      // Check if the project already exists
      var existingProjects = await (_db.select(_db.project)
            ..where((tbl) => tbl.name.equals(projectName)))
          .get();

      if (existingProjects.isEmpty) {
        // Create a new project if it doesn't exist
        var newProject = Project.byName(projectName);
        await upsertProject(newProject);
      }
    }
  }

  /// Batch insert multiple projects within a single transaction
  /// This method provides better performance for bulk operations
  Future<void> batchInsertProjects(List<Project> projects) async {
    return await _db.transaction(() async {
      for (var project in projects) {
        await _db.into(_db.project).insertOnConflictUpdate(
          ProjectCompanion(
            id: project.id != null ? Value(project.id!) : Value.absent(),
            name: Value(project.name),
            colorCode: Value(project.colorValue),
            colorName: Value(project.colorName),
          ),
        );
      }
    });
  }

  /// Get existing project names from a list of names for bulk existence checking
  /// Returns a Set of project names that already exist in the database
  Future<Set<String>> getExistingProjectNames(List<String> names) async {
    final query = _db.select(_db.project)
      ..where((tbl) => tbl.name.isIn(names));
    final results = await query.get();
    return results.map((p) => p.name).toSet();
  }
}
