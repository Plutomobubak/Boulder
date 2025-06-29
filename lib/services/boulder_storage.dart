import 'package:hive/hive.dart';
import '../models/boulder.dart';

class BoulderStorage {
  static final _box = Hive.box<Boulder>('boulders');

  static Future<void> saveBoulder(Boulder boulder) async {
    await _box.add(boulder);
  }

  static Future<void> updateBoulder(String formerName,Boulder boulder) async {
    final key = _box.keys.firstWhere(
          (k) => _box.get(k)?.name == formerName,
      orElse: () => null,
    );
    if (key != null) {
      await _box.put(key, boulder);
    }
  }

  static Future<void> deleteBoulder(Boulder boulder) async {
    await boulder.delete(); // assuming it's HiveObject
  }

  static List<Boulder> getAllBoulders() {
    return _box.values.toList();
  }
}