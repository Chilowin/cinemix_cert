part of 'catalog_cubit.dart';

enum CatalogStatus { loading, success, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.items = const [],
    this.isFromCache = false,
    this.message,
  });

  final CatalogStatus status;
  final List<MediaItem> items;
  final bool isFromCache;
  final String? message;

  @override
  List<Object?> get props => [status, items, isFromCache, message];
}
