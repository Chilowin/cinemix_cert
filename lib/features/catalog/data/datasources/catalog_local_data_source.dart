import '../../../../core/cache/cache_service.dart';
import '../../domain/entities/media_category.dart';
import '../models/media_item_model.dart';

class CatalogLocalDataSource {
  CatalogLocalDataSource(this._cache);

  final CacheService _cache;

  String _key(MediaCategory category) => 'catalog_${category.name}';

  Future<void> save(MediaCategory category, List<MediaItemModel> items) {
    return _cache.write(_key(category), items.map((e) => e.toJson()).toList());
  }

  List<MediaItemModel>? read(MediaCategory category) {
    try {
      final raw = _cache.read(_key(category));
      if (raw is! List) return null;
      return raw
          .map(
            (e) => MediaItemModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }
}
