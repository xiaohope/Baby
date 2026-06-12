import 'package:uuid/uuid.dart';

class TemperatureRecord {
  final String id;
  final double temperature;
  final DateTime time;
  final String? note;

  TemperatureRecord({
    String? id,
    required this.temperature,
    required this.time,
    this.note,
  }) : id = id ?? const Uuid().v4();
}
