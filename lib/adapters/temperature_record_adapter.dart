import 'package:hive/hive.dart';
import '../models/temperature_record.dart';

part 'temperature_record.g.dart';

@HiveType(typeId: 9)
class TemperatureRecordBox extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late double temperature;
  @HiveField(2) late DateTime time;
  @HiveField(3) String? note;

  TemperatureRecordBox();

  TemperatureRecordBox.fromModel(TemperatureRecord record) {
    id = record.id;
    temperature = record.temperature;
    time = record.time;
    note = record.note;
  }

  TemperatureRecord toModel() => TemperatureRecord(id: id, temperature: temperature, time: time, note: note);
}
