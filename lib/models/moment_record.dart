import 'package:uuid/uuid.dart';

class MomentRecord {
  final String id;
  final DateTime date;
  final String text;
  final List<String> imagePaths;
  final String userName;

  MomentRecord({
    String? id,
    required this.date,
    this.text = '',
    List<String>? imagePaths,
    this.userName = '宝宝',
  }) : id = id ?? const Uuid().v4(),
       imagePaths = imagePaths ?? [];
}
