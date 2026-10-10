import '../../../catalog/domain/entities/media_item.dart';

abstract class FavoritesRepository {
  Future<List<MediaItem>> getAll();

  Future<void> add(MediaItem item);

  Future<void> remove(int id);
}
