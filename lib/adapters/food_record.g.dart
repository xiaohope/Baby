// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_record_adapter.dart';

class FoodRecordBoxAdapter extends TypeAdapter<FoodRecordBox> {
  @override
  final int typeId = 8;

  @override
  FoodRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = FoodRecordBox();
    result.id = fields[0] as String;
    result.name = fields[1] as String;
    result.portion = fields[2] as String?;
    result.feeling = fields[3] as String?;
    result.time = fields[4] as DateTime;
    result.note = fields[5] as String?;
    return result;
  }

  @override
  void write(BinaryWriter writer, FoodRecordBox obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.portion)
      ..writeByte(3)..write(obj.feeling)
      ..writeByte(4)..write(obj.time)
      ..writeByte(5)..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
