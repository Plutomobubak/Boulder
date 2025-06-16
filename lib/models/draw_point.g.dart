// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_point.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawPointAdapter extends TypeAdapter<DrawPoint> {
  @override
  final int typeId = 1;

  @override
  DrawPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawPoint(
      dx: fields[0] as double,
      dy: fields[1] as double,
      type: fields[2] as int,
      size: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DrawPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dx)
      ..writeByte(1)
      ..write(obj.dy)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
