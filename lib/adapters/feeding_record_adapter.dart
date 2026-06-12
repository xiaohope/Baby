import 'package:hive/hive.dart';
import '../models/feeding_record.dart';

part 'feeding_record.g.dart';

@HiveType(typeId: 0)
class FeedingRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime time;

  @HiveField(2)
  late int type;

  @HiveField(3)
  int? breastMinutes;

  @HiveField(4)
  int? bottleMl;

  @HiveField(5)
  String? note;

  @HiveField(6)
  int? breastSide;

  FeedingRecordBox.fromModel(FeedingRecord record) {
    id = record.id;
    time = record.time;
    type = record.type.index;
    breastMinutes = record.breastMinutes;
    bottleMl = record.bottleMl;
    note = record.note;
    breastSide = record.breastSide?.index;
  }

  FeedingRecord toModel() {
    return FeedingRecord(
      id: id,
      time: time,
      type: FeedingType.values[type],
      breastMinutes: breastMinutes,
      bottleMl: bottleMl,
      note: note,
      breastSide: breastSide != null ? BreastSide.values[breastSide!] : null,
    );
  }
}
