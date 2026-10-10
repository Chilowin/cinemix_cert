import '../../domain/entities/media_item.dart';

class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.releaseDate,
    super.voteAverage,
  });

  factory MediaItemModel.fromEntity(MediaItem item) {
    return MediaItemModel(
      id: item.id,
      title: item.title,
      overview: item.overview,
      posterPath: item.posterPath,
      releaseDate: item.releaseDate,
      voteAverage: item.voteAverage,
    );
  }

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'release_date': releaseDate,
        'vote_average': voteAverage,
      };
}
