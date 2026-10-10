import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  CacheService(this._box);

  final Box<String> _box;

  static const String boxName = 'app_cache';

  static Future<CacheService> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(boxName);
    return CacheService(box);
  }

  Future<void> write(String key, Object data) {
    return _box.put(key, jsonEncode(data));
  }

  dynamic read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> clear() => _box.clear();
}
