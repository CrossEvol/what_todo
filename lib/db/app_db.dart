import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../models/setting_type.dart';
import 'tables.dart';
import 'package:flutter/material.dart' hide Table;

part 'app_db.g.dart';

@DriftDatabase(tables: [Project, Task, Label, TaskLabel, Profile, Setting])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await into(project).insert(ProjectCompanion(
            id: Value(1),
            name: Value('Inbox'),
            colorName: Value('Grey'),
            colorCode: Value(Colors.grey.value),
          ));
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1 && to == 2) {
            await m.createTable(profile);
            await into(profile).insert(ProfileCompanion(
                name: Value('Agnimon Frontier'),
                email: Value('AgnimonFrontier@gmail.com'),
                avatarUrl: Value('assets/Agnimon.jpg'),
                updatedAt: Value(DateTime.now().millisecondsSinceEpoch)));
          }
          if (from == 2 && to == 3) {
            await m.createTable(setting);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tasks.db'));
    return NativeDatabase(
      file,
      logStatements: true,
    );
  });
}
