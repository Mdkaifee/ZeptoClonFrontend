import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/categories/cubit/categories_state.dart';
import 'package:flutter_application_1/features/categories/data/repositories/category_repository.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(const CategoriesState());

  final CategoryRepository _categoryRepository;

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (state.status == CategoriesStatus.loading && !forceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        status: CategoriesStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final categories = await _categoryRepository.fetchCategories();
      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
