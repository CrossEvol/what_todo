import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_app/db/app_db.steps.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../models/setting_type.dart';
import '../models/reminder/reminder_type.dart';
import 'tables.dart';
import 'package:flutter/material.dart' hide Table;

part 'app_db.g.dart';

@DriftDatabase(tables: [
  Project,
  Task,
  Label,
  TaskLabel,
  Profile,
  Setting,
  DriftSchema,
  Reminder,
  Resource
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase.test(super.connection);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: stepByStep(from1To2: (m, schema) async {
        m.addColumn(schema.task, schema.task.updatedAt);
      }, from2To3: (Migrator m, Schema3 schema) async {
        m.dropColumn(schema.task, 'due_date');
      }, from3To4: (Migrator m, Schema4 schema) async {
        m.addColumn(schema.task, schema.task.dueDate);
      }, from4To5: (Migrator m, Schema5 schema) async {
        m.dropColumn(schema.task, 'updated_at');
      }, from5To6: (Migrator m, Schema6 schema) async {
        m.createTable(schema.driftSchema);
      }, from6To7: (Migrator m, Schema7 schema) async {
        m.addColumn(schema.task, schema.task.order);
      }, from7To8: (Migrator m, Schema8 schema) async {
        await m.createTable(schema.reminder);
      }, from8To9: (Migrator m, Schema9 schema) async {
        await m.addColumn(schema.reminder, schema.reminder.updateTime);
      }, from9To10: (Migrator m, Schema10 schema) async {
        m.createTable(schema.resource);
      }, from10To11: (Migrator m, Schema11 schema) async {
        await m.alterTable(TableMigration(schema.setting));
        await m.database.customStatement('UPDATE resource SET task_id = NULL WHERE task_id = -1;');
        await m.alterTable(TableMigration(schema.resource));
      }),
      beforeOpen: (details) async {
        // initial creation
        if (details.wasCreated) {
          await into(project).insert(ProjectCompanion(
            id: Value(1),
            name: Value('Inbox'),
            colorName: Value('Grey'),
            colorCode: Value(Colors.grey.value),
          ));
          await into(profile).insert(ProfileCompanion(
              name: Value('Agnimon Frontier'),
              email: Value('AgnimonFrontier@gmail.com'),
              avatarUrl: Value('assets/Agnimon.jpg'),
              updatedAt: Value(DateTime.now().millisecondsSinceEpoch)));
        }

        // upgrade
        if (details.hadUpgrade) {
          if (details.versionBefore == 1 && details.versionNow == 2) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE task SET updated_at = datetime(due_date/1000, 'unixepoch', 'localtime')");

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 2 && details.versionNow == 3) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 3 && details.versionNow == 4) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement("UPDATE task SET due_date = updated_at");

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 4 && details.versionNow == 5) {}
        }
      });
}

LazyDatabase _openConnection() {
  const isTest = bool.fromEnvironment('IS_TEST');
  const dbName = isTest ? 'tasks.test.db' : 'tasks.db';

  if (isTest) {
    logger.info('Use the database of path => $dbName ...');
  }

  // TODO: should decouple the data to application directory
  if (Platform.isAndroid) {
    return LazyDatabase(() async {
      final dbFolder = await getExternalStorageDirectory();
      final file = File(p.join(dbFolder!.path, dbName));
      resetDatabase(isTest, file);
      return NativeDatabase(
        file,
        logStatements: true,
      );
    });
  }

  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));
    resetDatabase(isTest, file);
    return NativeDatabase(
      file,
      logStatements: true,
    );
  });
}

void resetDatabase(bool isTest, File file) {
  if (isTest && file.existsSync()) {
    logger.info('Delete the database => ${file.absolute.path}');
    file.deleteSync(recursive: false);
    logger.info('Create the database => ${file.absolute.path}');
    file.createSync();
  }
}
