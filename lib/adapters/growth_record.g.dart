// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_record_adapter.dart';

class GrowthRecordBoxAdapter extends TypeAdapter<GrowthRecordBox> {
  @override
  final int typeId = 3;

  @override
  GrowthRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = GrowthRecordBox();
    result.id = fields[0] as String;
    result.date = fields[1] as DateTime;
    result.weightKg = fields[2] as double?;
    result.heightCm = fields[3] as double?;
    result.headCircumferenceCm = fields[4] as double?;
    result.note = fields[5] as String?;
    return result;
  }

  @override
  void write(BinaryWriter writer, GrowthRecordBox obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.headCircumferenceCm)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
