import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/catalog/data/repositories/product_repository.dart';
import 'package:flutter_application_1/features/catalog/cubit/catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const CatalogState());

  final ProductRepository _productRepository;

  Future<void> fetchProducts() async {
    emit(state.copyWith(status: CatalogStatus.loading, errorMessage: null));
    try {
      final products = await _productRepository.fetchProducts();
      emit(
        state.copyWith(
          status: CatalogStatus.success,
          products: products,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
