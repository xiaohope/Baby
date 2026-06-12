import 'package:uuid/uuid.dart';

class SupplementRecord {
  final String id;
  final DateTime date;
  final List<String> items; // 用户自定义补充剂列表

  SupplementRecord({
    String? id,
    required this.date,
    List<String>? items,
  }) : id = id ?? const Uuid().v4(),
       items = items ?? [];
}
