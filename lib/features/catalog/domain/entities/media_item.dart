import 'package:equatable/equatable.dart';

class MediaItem extends Equatable {
  const MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    this.voteAverage = 0,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w342$posterPath';

  @override
  List<Object?> get props =>
      [id, title, overview, posterPath, releaseDate, voteAverage];
}
