import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/media_category.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/catalog_repository.dart';

part 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository, this.category) : super(const CatalogState());

  final CatalogRepository _repository;
  final MediaCategory category;

  Future<void> load() async {
    emit(CatalogState(status: CatalogStatus.loading, items: state.items));
    try {
      final result = await _repository.getItems(category);
      emit(
        CatalogState(
          status: CatalogStatus.success,
          items: result.items,
          isFromCache: result.isFromCache,
          message: result.failure?.message,
        ),
      );
    } on Failure catch (failure) {
      emit(
        CatalogState(
          status: CatalogStatus.failure,
          items: state.items,
          message: failure.message,
        ),
      );
    } catch (_) {
      emit(
        CatalogState(
          status: CatalogStatus.failure,
          items: state.items,
          message: const UnknownFailure().message,
        ),
      );
    }
  }
}
