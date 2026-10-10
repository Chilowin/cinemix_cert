import '../entities/catalog_result.dart';
import '../entities/media_category.dart';

abstract class CatalogRepository {
  Future<CatalogResult> getItems(MediaCategory category);
}
