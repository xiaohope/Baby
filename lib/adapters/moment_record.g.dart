// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_record_adapter.dart';

class MomentRecordBoxAdapter extends TypeAdapter<MomentRecordBox> {
  @override
  final int typeId = 6;

  @override
  MomentRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = MomentRecordBox();
    result.id = fields[0] as String;
    result.date = fields[1] as DateTime;
    result.text = fields[2] as String;
    result.imagePaths = (fields[3] as List).cast<String>();
    return result;
  }

  @override
  void write(BinaryWriter writer, MomentRecordBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MomentRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
