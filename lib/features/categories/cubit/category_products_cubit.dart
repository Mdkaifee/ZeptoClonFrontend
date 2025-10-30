import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/categories/cubit/category_products_state.dart';
import 'package:flutter_application_1/features/categories/data/repositories/category_repository.dart';

class CategoryProductsCubit extends Cubit<CategoryProductsState> {
  CategoryProductsCubit({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(const CategoryProductsState());

  final CategoryRepository _categoryRepository;

  Future<void> fetchProducts(String category) async {
    emit(
      state.copyWith(
        status: CategoryProductsStatus.loading,
        category: category,
        errorMessage: null,
      ),
    );
    try {
      final products =
          await _categoryRepository.fetchProductsByCategory(category);
      emit(
        state.copyWith(
          status: CategoryProductsStatus.success,
          products: products,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryProductsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
