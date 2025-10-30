import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';

enum WishlistStatus { initial, loading, success, failure }

const _pendingIdSentinel = Object();

class WishlistState extends Equatable {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.products = const <ProductModel>[],
    this.isUpdating = false,
    this.errorMessage,
    this.infoMessage,
    this.pendingProductId,
  });

  final WishlistStatus status;
  final List<ProductModel> products;
  final bool isUpdating;
  final String? errorMessage;
  final String? infoMessage;
  final String? pendingProductId;

  Set<String> get productIds =>
      Set<String>.unmodifiable(products.map((product) => product.id));

  bool get isEmpty => products.isEmpty;

  WishlistState copyWith({
    WishlistStatus? status,
    List<ProductModel>? products,
    bool? isUpdating,
    String? errorMessage,
    String? infoMessage,
    Object? pendingProductId = _pendingIdSentinel,
  }) {
    return WishlistState(
      status: status ?? this.status,
      products: products ?? this.products,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
      pendingProductId: identical(pendingProductId, _pendingIdSentinel)
          ? this.pendingProductId
          : pendingProductId as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        isUpdating,
        errorMessage,
        infoMessage,
        pendingProductId,
      ];
}
