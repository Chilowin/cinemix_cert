import '../../../../core/cache/cache_service.dart';
import '../../../catalog/data/models/media_item_model.dart';
import '../../../catalog/domain/entities/media_item.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._cache);

  final CacheService _cache;

  static const String _key = 'favorites';

  List<MediaItemModel> _read() {
    try {
      final raw = _cache.read(_key);
      if (raw is! List) return [];
      return raw
          .map(
            (e) => MediaItemModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<MediaItemModel> items) {
    return _cache.write(_key, items.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<MediaItem>> getAll() async => _read();

  @override
  Future<void> add(MediaItem item) async {
    final items = _read();
    if (items.any((e) => e.id == item.id)) return;
    await _write([MediaItemModel.fromEntity(item), ...items]);
  }

  @override
  Future<void> remove(int id) async {
    final items = _read()..removeWhere((e) => e.id == id);
    await _write(items);
  }
}
