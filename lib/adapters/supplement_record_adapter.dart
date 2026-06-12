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
  late bool tookAD;

  @HiveField(3)
  late bool tookD3;

  @HiveField(4)
  late List<String> others;

  SupplementRecordBox.fromModel(SupplementRecord record) {
    id = record.id;
    date = record.date;
    tookAD = record.tookAD;
    tookD3 = record.tookD3;
    others = record.others;
  }

  SupplementRecord toModel() {
    return SupplementRecord(
      id: id,
      date: date,
      tookAD: tookAD,
      tookD3: tookD3,
      others: others,
    );
  }
}
