import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'draw_point.g.dart';

@HiveType(typeId: 1)
class DrawPoint extends HiveObject {
  @HiveField(0)
  double dx;

  @HiveField(1)
  double dy;

  @HiveField(2)
  int type; // store DrawType.index

  @HiveField(3)
  double size;

  DrawPoint({
    required this.dx,
    required this.dy,
    required this.type,
    required this.size,
  });

  // helper to get back Offset & DrawType
  Offset get offset => Offset(dx, dy);
}
