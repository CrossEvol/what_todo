import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:sqflite/sqflite.dart';

class LabelDB {
  static final LabelDB _labelDb = LabelDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  LabelDB._internal(this._appDatabase);

  static LabelDB get() {
    return _labelDb;
  }

  Future<bool> isLabelExits(Label label) async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery(
        "SELECT * FROM label WHERE name LIKE '${label.name}'");
    if (result.length == 0) {
      return await updateLabels(label).then((value) {
        return false;
      });
    } else {
      return true;
    }
  }

  Future updateLabels(Label label) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT OR REPLACE INTO '
          'label(name,colorCode,colorName)'
          ' VALUES("${label.name}", ${label.colorValue}, "${label.colorName}")');
    });
  }

  Future<List<Label>> getLabels() async {
    var db = await _appDatabase.getDb();
    var result = await db.rawQuery('SELECT * FROM label');
    List<Label> labels = [];
    for (Map<String, dynamic> item in result) {
      var myLabels = Label.fromMap(item);
      labels.add(myLabels);
    }
    return labels;
  }

  Future deleteLabel(int labelId) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM label WHERE id==$labelId;');
    });
  }
}
