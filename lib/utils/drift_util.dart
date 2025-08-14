
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/drift_schema/drift_schema_db.dart';

Future<void> migrate() async {
  var schemaDB = DriftSchemaDB.get();
  var existsSchema = await schemaDB.exists();
  if (!existsSchema) {
    schemaDB.createSchema(1);
  }
  // 1->2
  if ((await schemaDB.getMaximalVersion()) == 1) {
    if ((await schemaDB.shouldMigrate(1))) {
      schemaDB.createSchema(2);
      AppDatabase().customStatement(r'''
      WITH numbered_rows AS (
        SELECT 
          id,
          ROW_NUMBER() OVER (ORDER BY id) AS row_num
        FROM task
      )
      UPDATE task
      SET "order" = (
        SELECT row_num * 1000 
        FROM numbered_rows 
        WHERE numbered_rows.id = task.id
      );
      ''');
    }
  }
}
