// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_record_adapter.dart';

class MilestoneRecordBoxAdapter extends TypeAdapter<MilestoneRecordBox> {
  @override
  final int typeId = 4;

  @override
  MilestoneRecordBox read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final result = MilestoneRecordBox();
    result.id = fields[0] as String;
    result.date = fields[1] as DateTime;
    result.title = fields[2] as String;
    result.note = fields[3] as String?;
    result.category = fields[4] as String;
    return result;
  }

  @override
  void write(BinaryWriter writer, MilestoneRecordBox obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneRecordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
