// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record_adapter.dart';

class SleepRecordBoxAdapter extends TypeAdapter<SleepRecordBox> {
  @override
  final int typeId = 2;

  @override
  SleepRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = SleepRecordBox();
    result.id = fields[0] as String;
    result.startTime = fields[1] as DateTime;
    result.endTime = fields[2] as DateTime?;
    result.quality = fields[3] as int?;
    result.note = fields[4] as String?;
    return result;
  }

  @override
  void write(BinaryWriter writer, SleepRecordBox obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.quality)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
