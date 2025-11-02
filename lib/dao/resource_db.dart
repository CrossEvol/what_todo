import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/models/resource.dart';

class ResourceDB {
  static final ResourceDB _resourceDb = ResourceDB._internal(AppDatabase());

  AppDatabase _db;

  //private internal constructor to make it singleton
  ResourceDB._internal(this._db);

  static ResourceDB get() {
    return _resourceDb;
  }

  /// Fetch all resources associated with a specific task
  Future<List<ResourceModel>> getResourcesByTaskId(int taskId) async {
    final result = await (_db.select(_db.resource)
          ..where((tbl) => tbl.taskId.equals(taskId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createTime)]))
        .get();
    return result.map((row) => ResourceModel.fromMap(row.toJson())).toList();
  }

  /// Insert a new resource record
  Future<int> insertResource(ResourceModel resource) async {
    return await _db.into(_db.resource).insert(ResourceCompanion(
          path: Value(resource.path),
          taskId: resource.taskId != null
              ? Value(resource.taskId!)
              : Value.absent(),
          createTime: Value(resource.createTime ?? DateTime.now()),
        ));
  }

  /// Delete a resource by its ID
  Future<int> deleteResource(int resourceId) async {
    return await (_db.delete(_db.resource)
          ..where((tbl) => tbl.id.equals(resourceId)))
        .go();
  }

  /// Delete all resources associated with a specific task
  Future<int> deleteResourcesByTaskId(int taskId) async {
    return await (_db.delete(_db.resource)
          ..where((tbl) => tbl.taskId.equals(taskId)))
        .go();
  }

  /// Get a specific resource by its ID
  Future<ResourceModel?> getResourceById(int resourceId) async {
    final result = await (_db.select(_db.resource)
          ..where((tbl) => tbl.id.equals(resourceId)))
        .getSingleOrNull();
    return result != null ? ResourceModel.fromMap(result.toJson()) : null;
  }

  /// Get the next available ID for a new resource
  Future<int> getNextResourceId() async {
    final result = await _db
        .customSelect(
            'SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM resource')
        .getSingle();
    return result.data['next_id'] as int;
  }

  /// Fetch all resources that are not associated with any task (taskId is null)
  Future<List<ResourceModel>> getUnassignedResources() async {
    final result = await (_db.select(_db.resource)
          ..where((tbl) => tbl.taskId.equals(-1))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createTime)]))
        .get();
    return result.map((row) => ResourceModel.fromMap(row.toJson())).toList();
  }

  /// Update the taskId of a resource to associate it with a task
  Future<bool> updateResourceTaskId(int resourceId, int taskId) async {
    final result = await (_db.update(_db.resource)
          ..where((tbl) => tbl.id.equals(resourceId)))
        .write(ResourceCompanion(taskId: Value(taskId)));
    return result > 0;
  }
}
