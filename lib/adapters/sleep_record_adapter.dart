import 'package:hive/hive.dart';
import '../models/sleep_record.dart';

part 'sleep_record.g.dart';

@HiveType(typeId: 2)
class SleepRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  int? quality;

  @HiveField(4)
  String? note;

  SleepRecordBox.fromModel(SleepRecord record) {
    id = record.id;
    startTime = record.startTime;
    endTime = record.endTime;
    quality = record.quality?.index;
    note = record.note;
  }

  SleepRecord toModel() {
    return SleepRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      quality: quality != null ? SleepQuality.values[quality!] : null,
      note: note,
    );
  }
}
