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

  Future<bool> isLabelExists(Label label) async {
    var result = await (_db.select(_db.label)
          ..where((tbl) => tbl.name.equals(label.name)))
        .get();
    if (result.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future insertLabel(Label label) async {
    await _db.into(_db.label).insertOnConflictUpdate(
          LabelCompanion(
            id: Value.absent(),
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

  Future<List<LabelWithCount>> getLabelsWithCount() async {
    final query =
        _db.select(_db.label).addColumns([_db.taskLabel.labelId.count()]).join([
      leftOuterJoin(
          _db.taskLabel, _db.taskLabel.labelId.equalsExp(_db.label.id)),
    ])
          ..groupBy([_db.label.id]);

    final result = await query.get();

    return result.map((row) {
      final labelData = row.readTable(_db.label);
      final count = row.read(_db.taskLabel.labelId.count()) ?? 0;

      return LabelWithCount.fromMap({
        ...labelData.toJson(),
        'count': count,
      });
    }).toList();
  }

  Future<List<Label>> getLabelsByNames(List<String> labelNames) async {
    var query = _db.select(_db.label);
    query.where((tbl) => tbl.name.isIn(labelNames));
    var result = await query.get();
    return result.map((item) => Label.fromMap(item.toJson())).toList();
  }

  Future<bool> deleteLabel(int labelId) async {
    return await _db.transaction(() async {
      final result = await (_db.delete(_db.label)
            ..where((tbl) => tbl.id.equals(labelId)))
          .go();
      await (_db.delete(_db.taskLabel)
            ..where((tbl) => tbl.labelId.equals(labelId)))
          .go();
      return result > 0;
    });
  }
}
