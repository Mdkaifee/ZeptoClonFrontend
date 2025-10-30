import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';

enum CatalogStatus { initial, loading, success, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const <ProductModel>[],
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<ProductModel> products;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogStatus? status,
    List<ProductModel>? products,
    String? errorMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}
