import 'package:dio/dio.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/media_category.dart';
import '../models/media_item_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dio);

  final Dio _dio;

  String _path(MediaCategory category) => switch (category) {
        MediaCategory.popularMovies => '/movie/popular',
        MediaCategory.popularSeries => '/tv/popular',
        MediaCategory.upcomingMovies => '/movie/upcoming',
      };

  Future<List<MediaItemModel>> fetch(MediaCategory category) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_path(category));
      final results = response.data?['results'] as List<dynamic>? ?? [];
      return results
          .map((e) => MediaItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
