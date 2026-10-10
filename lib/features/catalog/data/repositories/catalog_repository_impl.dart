import '../../../../core/error/failure.dart';
import '../../domain/entities/catalog_result.dart';
import '../../domain/entities/media_category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required CatalogRemoteDataSource remote,
    required CatalogLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;

  @override
  Future<CatalogResult> getItems(MediaCategory category) async {
    try {
      final items = await _remote.fetch(category);
      await _local.save(category, items);
      return CatalogResult(items: items);
    } on Failure catch (failure) {
      final cached = _local.read(category);
      if (cached == null || cached.isEmpty) rethrow;
      return CatalogResult(items: cached, failure: failure);
    }
  }
}
