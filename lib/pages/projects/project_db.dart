import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/projects/project.dart';

import 'package:sqflite/sqflite.dart';

class ProjectDB {
  static final ProjectDB _projectDb = ProjectDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  ProjectDB._internal(this._appDatabase);

  static ProjectDB get() {
    return _projectDb;
  }

  Future<List<Project>> getProjects({bool isInboxVisible = true}) async {
    var db = await _appDatabase.getDb();

    var whereClause = isInboxVisible ? ";" : " WHERE id!=1;";
    var result =
        await db.rawQuery('SELECT * FROM project $whereClause');
    List<Project> projects = [];
    for (Map<String, dynamic> item in result) {
      var myProject = Project.fromMap(item);
      projects.add(myProject);
    }
    return projects;
  }

  Future insertOrReplace(Project project) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT OR REPLACE INTO '
          'project(id,name,colorCode,colorName)'
          ' VALUES(${project.id},"${project.name}", ${project.colorValue}, "${project.colorName}")');
    });
  }

  Future deleteProject(int projectID) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM project WHERE id==$projectID;');
    });
  }
}
