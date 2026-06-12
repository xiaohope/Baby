// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplement_record_adapter.dart';

class SupplementRecordBoxAdapter extends TypeAdapter<SupplementRecordBox> {
  @override
  final int typeId = 5;

  @override
  SupplementRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = SupplementRecordBox();
    result.id = fields[0] as String;
    result.date = fields[1] as DateTime;
    result.tookAD = fields[2] as bool;
    result.tookD3 = fields[3] as bool;
    result.others = (fields[4] as List).cast<String>();
    return result;
  }

  @override
  void write(BinaryWriter writer, SupplementRecordBox obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.tookAD)
      ..writeByte(3)
      ..write(obj.tookD3)
      ..writeByte(4)
      ..write(obj.others);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
