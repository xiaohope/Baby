import 'package:hive/hive.dart';
import '../models/supplement_record.dart';

part 'supplement_record.g.dart';

@HiveType(typeId: 5)
class SupplementRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late List<String> items;

  SupplementRecordBox();

  SupplementRecordBox.fromModel(SupplementRecord record) {
    id = record.id;
    date = record.date;
    items = record.items;
  }

  SupplementRecord toModel() {
    return SupplementRecord(
      id: id,
      date: date,
      items: items,
    );
  }
}
