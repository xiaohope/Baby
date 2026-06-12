import 'package:uuid/uuid.dart';

class FoodRecord {
  final String id;
  final String name;
  final String? portion;
  final String? feeling;
  final DateTime time;
  final String? note;

  FoodRecord({
    String? id,
    required this.name,
    this.portion,
    this.feeling,
    required this.time,
    this.note,
  }) : id = id ?? const Uuid().v4();
}
