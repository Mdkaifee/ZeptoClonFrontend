import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';

enum CategoryProductsStatus { initial, loading, success, failure }

class CategoryProductsState extends Equatable {
  const CategoryProductsState({
    this.status = CategoryProductsStatus.initial,
    this.products = const <ProductModel>[],
    this.errorMessage,
    this.category = '',
  });

  final CategoryProductsStatus status;
  final List<ProductModel> products;
  final String? errorMessage;
  final String category;

  CategoryProductsState copyWith({
    CategoryProductsStatus? status,
    List<ProductModel>? products,
    String? errorMessage,
    String? category,
  }) {
    return CategoryProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage, category];
}
