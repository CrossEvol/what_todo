// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:test/test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    final versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase.test(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Simple tests ensure the schema is transformed correctly, but some
  // migrations benefit from a test verifying that data is transformed correctly
  // too. This is particularly true for migrations that change existing columns
  // (e.g. altering their type or constraints). Migrations that only add tables
  // or columns typically don't need these advanced tests.
  // TODO: Check whether you have migrations that could benefit from these tests
  // and adapt this example to your database if necessary:
  test("migration from v1 to v2 does not corrupt data", () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldProjectData = <v1.ProjectData>[];
    final expectedNewProjectData = <v2.ProjectData>[];

    final oldTaskData = <v1.TaskData>[];
    final expectedNewTaskData = <v2.TaskData>[];

    final oldLabelData = <v1.LabelData>[];
    final expectedNewLabelData = <v2.LabelData>[];

    final oldTaskLabelData = <v1.TaskLabelData>[];
    final expectedNewTaskLabelData = <v2.TaskLabelData>[];

    final oldProfileData = <v1.ProfileData>[];
    final expectedNewProfileData = <v2.ProfileData>[];

    final oldSettingData = <v1.SettingData>[];
    final expectedNewSettingData = <v2.SettingData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.test,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.project, oldProjectData);
        batch.insertAll(oldDb.task, oldTaskData);
        batch.insertAll(oldDb.label, oldLabelData);
        batch.insertAll(oldDb.taskLabel, oldTaskLabelData);
        batch.insertAll(oldDb.profile, oldProfileData);
        batch.insertAll(oldDb.setting, oldSettingData);
      },
      validateItems: (newDb) async {
        expect(expectedNewProjectData, await newDb.select(newDb.project).get());
        expect(expectedNewTaskData, await newDb.select(newDb.task).get());
        expect(expectedNewLabelData, await newDb.select(newDb.label).get());
        expect(expectedNewTaskLabelData,
            await newDb.select(newDb.taskLabel).get());
        expect(expectedNewProfileData, await newDb.select(newDb.profile).get());
        expect(expectedNewSettingData, await newDb.select(newDb.setting).get());
      },
    );
  });
}
