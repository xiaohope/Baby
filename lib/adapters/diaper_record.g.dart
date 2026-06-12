// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diaper_record_adapter.dart';

class DiaperRecordBoxAdapter extends TypeAdapter<DiaperRecordBox> {
  @override
  final int typeId = 1;

  @override
  DiaperRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = DiaperRecordBox();
    result.id = fields[0] as String;
    result.time = fields[1] as DateTime;
    result.type = fields[2] as int;
    result.poopColor = fields[3] as String?;
    result.note = fields[4] as String?;
    return result;
  }

  @override
  void write(BinaryWriter writer, DiaperRecordBox obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.poopColor)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaperRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
