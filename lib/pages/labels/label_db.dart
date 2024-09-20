import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/labels/label.dart';

class LabelDB {
  static final LabelDB _labelDb = LabelDB._internal(AppDatabase());

  AppDatabase _db;

  //private internal constructor to make it singleton
  LabelDB._internal(this._db);

  static LabelDB get() {
    return _labelDb;
  }

  Future<bool> isLabelExits(Label label) async {
    var result = await (_db.select(_db.label)
          ..where((tbl) => tbl.name.equals(label.name)))
        .get();
    if (result.isEmpty) {
      await updateLabels(label);
      return false;
    } else {
      return true;
    }
  }

  Future updateLabels(Label label) async {
    await _db.into(_db.label).insertOnConflictUpdate(
          LabelCompanion(
            name: Value(label.name),
            colorCode: Value(label.colorValue),
            colorName: Value(label.colorName),
          ),
        );
  }

  Future<List<Label>> getLabels() async {
    var result = await _db.select(_db.label).get();
    return result.map((item) => Label.fromMap(item.toJson())).toList();
  }

  Future<List<Label>> getLabelsByNames(List<String> labelNames) async {
    var query = _db.select(_db.label);
    query.where((tbl) => tbl.name.isIn(labelNames));
    var result = await query.get();
    return result.map((item) => Label.fromMap(item.toJson())).toList();
  }

  Future deleteLabel(int labelId) async {
    await (_db.delete(_db.label)..where((tbl) => tbl.id.equals(labelId))).go();
  }
}
