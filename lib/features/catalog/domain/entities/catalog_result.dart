import '../../../../core/error/failure.dart';
import 'media_item.dart';

class CatalogResult {
  const CatalogResult({required this.items, this.failure});

  final List<MediaItem> items;
  final Failure? failure;

  bool get isFromCache => failure != null;
}
