// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_record_adapter.dart';

class SimpleRecordBoxAdapter extends TypeAdapter<SimpleRecordBox> {
  @override
  final int typeId = 7;

  @override
  SimpleRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = SimpleRecordBox();
    result.id = fields[0] as String;
    result.category = fields[1] as String;
    result.time = fields[2] as DateTime;
    result.note = fields[3] as String;
    return result;
  }

  @override
  void write(BinaryWriter writer, SimpleRecordBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
