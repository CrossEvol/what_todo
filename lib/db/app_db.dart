import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/models/task_label.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';

/// This is the singleton database class which handlers all database transactions
/// All the task raw queries is handle here and return a Future<T> with result
class AppDatabase {
  static final AppDatabase _appDatabase = AppDatabase._internal();

  //private internal constructor to make it singleton
  AppDatabase._internal();

  late Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  bool didInit = false;

  /// Use this method to access the database which will provide you future of [Database],
  /// because initialization of the database (it has to go through the method channel)
  Future<Database> getDb() async {
    if (!didInit) await _init();
    return _database;
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tasks.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await _createProjectTable(db);
      await _createTaskTable(db);
      await _createLabelTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute("DROP TABLE Task");
      await db.execute("DROP TABLE project");
      await db.execute("DROP TABLE taskLabel");
      await db.execute("DROP TABLE label");
      await _createProjectTable(db);
      await _createTaskTable(db);
      await _createLabelTable(db);
    });
    didInit = true;
  }

  Future _createProjectTable(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE project ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "colorName TEXT,"
          "colorCode INTEGER);");
      txn.rawInsert('INSERT INTO project(id, name, colorName, colorCode)'
          ' VALUES(1, "Inbox", "Grey", ${Colors.grey.value});');
    });
  }

  Future _createLabelTable(Database db) {
    return db.transaction((Transaction txn) async {
      await txn.execute("CREATE TABLE label ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "colorName TEXT,"
          "colorCode INTEGER);");
      await txn.execute("CREATE TABLE taskLabel ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "taskId INTEGER,"
          "labelId INTEGER,"
          "FOREIGN KEY(taskId) REFERENCES Task(id) ON DELETE CASCADE,"
          "FOREIGN KEY(labelId) REFERENCES label(id) ON DELETE CASCADE);");
    });
  }

  Future _createTaskTable(Database db) {
    return db.execute("CREATE TABLE Task ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "comment TEXT,"
        "dueDate LONG,"
        "priority LONG,"
        "projectId LONG,"
        "status LONG,"
        "FOREIGN KEY(projectId) REFERENCES project(id) ON DELETE CASCADE);");
  }
}
