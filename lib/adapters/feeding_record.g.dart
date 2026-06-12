// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_record_adapter.dart';

class FeedingRecordBoxAdapter extends TypeAdapter<FeedingRecordBox> {
  @override
  final int typeId = 0;

  @override
  FeedingRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = FeedingRecordBox();
    result.id = fields[0] as String;
    result.time = fields[1] as DateTime;
    result.type = fields[2] as int;
    result.breastMinutes = fields[3] as int?;
    result.bottleMl = fields[4] as int?;
    result.note = fields[5] as String?;
    result.breastSide = fields[6] as int?;
    return result;
  }

  @override
  void write(BinaryWriter writer, FeedingRecordBox obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.breastMinutes)
      ..writeByte(4)
      ..write(obj.bottleMl)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.breastSide);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
