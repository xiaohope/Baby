import 'package:uuid/uuid.dart';

class SimpleRecord {
  final String id;
  final String category; // 'pee', 'poop', 'medication'
  final DateTime time;
  final String note;

  SimpleRecord({
    String? id,
    required this.category,
    required this.time,
    this.note = '',
  }) : id = id ?? const Uuid().v4();
}
