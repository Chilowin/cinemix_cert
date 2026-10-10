import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/entities/media_item.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesCubit extends Cubit<List<MediaItem>> {
  FavoritesCubit(this._repository) : super(const []);

  final FavoritesRepository _repository;

  Future<void> load() async {
    emit(await _repository.getAll());
  }

  Future<void> toggle(MediaItem item) async {
    if (state.any((e) => e.id == item.id)) {
      await _repository.remove(item.id);
    } else {
      await _repository.add(item);
    }
    await load();
  }
}
