import 'package:hive/hive.dart';
import '../models/diaper_record.dart';

part 'diaper_record.g.dart';

@HiveType(typeId: 1)
class DiaperRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime time;

  @HiveField(2)
  late int type;

  @HiveField(3)
  String? poopColor;

  @HiveField(4)
  String? note;

  DiaperRecordBox();

  DiaperRecordBox.fromModel(DiaperRecord record) {
    id = record.id;
    time = record.time;
    type = record.type.index;
    poopColor = record.poopColor;
    note = record.note;
  }

  DiaperRecord toModel() {
    return DiaperRecord(
      id: id,
      time: time,
      type: DiaperType.values[type],
      poopColor: poopColor,
      note: note,
    );
  }
}
