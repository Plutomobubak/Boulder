import 'package:hive/hive.dart';
import '../models/boulder.dart';

class BoulderStorage {
  static final _box = Hive.box<Boulder>('boulders');

  static Future<void> saveBoulder(Boulder boulder) async {
    await _box.add(boulder);
  }

  static Future<void> deleteBoulder(Boulder boulder) async {
    await boulder.delete(); // assuming it's HiveObject
  }

  static List<Boulder> getAllBoulders() {
    return _box.values.toList();
  }
}