import 'package:hive/hive.dart';
import '../models/food_record.dart';

part 'food_record.g.dart';

@HiveType(typeId: 8)
class FoodRecordBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? portion;

  @HiveField(3)
  String? feeling;

  @HiveField(4)
  late DateTime time;

  @HiveField(5)
  String? note;

  FoodRecordBox();

  FoodRecordBox.fromModel(FoodRecord record) {
    id = record.id;
    name = record.name;
    portion = record.portion;
    feeling = record.feeling;
    time = record.time;
    note = record.note;
  }

  FoodRecord toModel() {
    return FoodRecord(
      id: id,
      name: name,
      portion: portion,
      feeling: feeling,
      time: time,
      note: note,
    );
  }
}
