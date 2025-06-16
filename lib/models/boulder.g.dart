// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boulder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoulderAdapter extends TypeAdapter<Boulder> {
  @override
  final int typeId = 0;

  @override
  Boulder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Boulder(
      imagePath: fields[0] as String,
      points: (fields[1] as List).cast<DrawPoint>(),
      name: fields[2] as String,
      grade: fields[3] as String,
      location: fields[4] as String,
      comment: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Boulder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.points)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.comment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoulderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
