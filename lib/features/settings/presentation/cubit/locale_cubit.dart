import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/cache_service.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._cache) : super(_restore(_cache));

  final CacheService _cache;

  static const String _key = 'settings_locale';
  static const String _system = 'system';

  static Locale? _restore(CacheService cache) {
    final code = cache.read(_key);
    if (code is String && code != _system) return Locale(code);
    return null;
  }

  Future<void> select(Locale? locale) {
    emit(locale);
    return _cache.write(_key, locale?.languageCode ?? _system);
  }
}
