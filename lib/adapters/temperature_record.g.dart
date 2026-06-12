// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_record_adapter.dart';

class TemperatureRecordBoxAdapter extends TypeAdapter<TemperatureRecordBox> {
  @override
  final int typeId = 9;

  @override
  TemperatureRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    final result = TemperatureRecordBox();
    result.id = fields[0] as String;
    result.temperature = fields[1] as double;
    result.time = fields[2] as DateTime;
    result.note = fields[3] as String?;
    return result;
  }

  @override
  void write(BinaryWriter writer, TemperatureRecordBox obj) {
    writer..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.temperature)
      ..writeByte(2)..write(obj.time)
      ..writeByte(3)..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureRecordBoxAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
