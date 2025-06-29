import 'package:hive/hive.dart';
import 'draw_point.dart';

part 'boulder.g.dart';

@HiveType(typeId: 0)
class Boulder extends HiveObject {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  List<DrawPoint> points;

  @HiveField(2)
  String name;

  @HiveField(3)
  int grade;

  @HiveField(4)
  String location;

  @HiveField(5)
  String comment;

  @HiveField(6)
  String author;

  @HiveField(7)
  bool isOwn;

  @HiveField(8)
  DateTime created_at;

  Boulder({
    required this.imagePath,
    required this.points,
    required this.name,
    required this.grade,
    required this.location,
    required this.comment,
    required this.author,
    required this.isOwn,
    required this.created_at,  // new field added here
  });
}
