import 'package:hive/hive.dart';
import '../models/boulder.dart';

class Settings {
  static final _box = Hive.box('settings');

  static Future<void> set(String key, dynamic value) async {
    await _box.put(key,value);
  }
  static Future<dynamic> get(String key, dynamic defaultValue) async {
    return await _box.get(key,defaultValue: defaultValue);
  }
}