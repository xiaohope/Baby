import 'package:hive/hive.dart';
import '../models/moment_record.dart';

part 'moment_record.g.dart';

@HiveType(typeId: 6)
class MomentRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String text;

  @HiveField(3)
  late List<String> imagePaths;

  MomentRecordBox();

  MomentRecordBox.fromModel(MomentRecord record) {
    id = record.id;
    date = record.date;
    text = record.text;
    imagePaths = record.imagePaths;
  }

  MomentRecord toModel() {
    return MomentRecord(
      id: id,
      date: date,
      text: text,
      imagePaths: imagePaths,
    );
  }
}
