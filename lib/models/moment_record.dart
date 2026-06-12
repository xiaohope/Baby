import 'package:uuid/uuid.dart';

class MomentRecord {
  final String id;
  final DateTime date;
  final String text;
  final List<String> imagePaths;

  MomentRecord({
    String? id,
    required this.date,
    this.text = '',
    List<String>? imagePaths,
  }) : id = id ?? const Uuid().v4(),
       imagePaths = imagePaths ?? [];
}
