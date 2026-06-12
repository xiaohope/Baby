import 'package:hive/hive.dart';
import '../models/milestone_record.dart';

part 'milestone_record.g.dart';

@HiveType(typeId: 4)
class MilestoneRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String title;

  @HiveField(3)
  String? note;

  @HiveField(4)
  late String category;

  MilestoneRecordBox();

  MilestoneRecordBox.fromModel(MilestoneRecord record) {
    id = record.id;
    date = record.date;
    title = record.title;
    note = record.note;
    category = record.category;
  }

  MilestoneRecord toModel() {
    return MilestoneRecord(
      id: id,
      date: date,
      title: title,
      note: note,
      category: category,
    );
  }
}
