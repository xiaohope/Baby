import 'package:hive/hive.dart';
import '../models/simple_record.dart';

part 'simple_record.g.dart';

@HiveType(typeId: 7)
class SimpleRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late DateTime time;

  @HiveField(3)
  late String note;

  SimpleRecordBox();

  SimpleRecordBox.fromModel(SimpleRecord record) {
    id = record.id;
    category = record.category;
    time = record.time;
    note = record.note;
  }

  SimpleRecord toModel() {
    return SimpleRecord(
      id: id,
      category: category,
      time: time,
      note: note,
    );
  }
}
