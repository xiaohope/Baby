import 'package:hive/hive.dart';
import '../models/growth_record.dart';

part 'growth_record.g.dart';

@HiveType(typeId: 3)
class GrowthRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  double? weightKg;

  @HiveField(3)
  double? heightCm;

  @HiveField(4)
  double? headCircumferenceCm;

  @HiveField(5)
  String? note;

  GrowthRecordBox();

  GrowthRecordBox.fromModel(GrowthRecord record) {
    id = record.id;
    date = record.date;
    weightKg = record.weightKg;
    heightCm = record.heightCm;
    headCircumferenceCm = record.headCircumferenceCm;
    note = record.note;
  }

  GrowthRecord toModel() {
    return GrowthRecord(
      id: id,
      date: date,
      weightKg: weightKg,
      heightCm: heightCm,
      headCircumferenceCm: headCircumferenceCm,
      note: note,
    );
  }
}
