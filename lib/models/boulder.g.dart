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

    // Handle grade field migration (old String to new int)
    int gradeValue;
    final dynamic oldGrade = fields[3];
    if (oldGrade is String) {
      gradeValue = int.tryParse(oldGrade) ?? 0; // or your default int
    } else if (oldGrade is int) {
      gradeValue = oldGrade;
    } else {
      gradeValue = 0; // fallback default
    }

    String authorValue = fields.containsKey(6) && (fields[6] as String).isNotEmpty
        ? fields[6] as String
        : 'anon';
    return Boulder(
      imagePath: fields[0] as String,
      points: (fields[1] as List).cast<DrawPoint>(),
      name: fields[2] as String,
      grade: gradeValue,
      location: fields[4] as String,
      comment: fields[5] as String,
      author: authorValue,
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
