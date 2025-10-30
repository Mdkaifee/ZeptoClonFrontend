import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';

enum CartStatus { initial, loading, success, failure }

const _sentinel = Object();

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const <CartItemModel>[],
    this.isUpdating = false,
    this.errorMessage,
    this.infoMessage,
    this.pendingProductId,
    this.pendingCartItemId,
  });

  final CartStatus status;
  final List<CartItemModel> items;
  final bool isUpdating;
  final String? errorMessage;
  final String? infoMessage;
  final String? pendingProductId;
  final String? pendingCartItemId;

  double get totalAmount =>
      items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    CartStatus? status,
    List<CartItemModel>? items,
    bool? isUpdating,
    String? errorMessage,
    String? infoMessage,
    Object? pendingProductId = _sentinel,
    Object? pendingCartItemId = _sentinel,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
      pendingProductId: identical(pendingProductId, _sentinel)
          ? this.pendingProductId
          : pendingProductId as String?,
      pendingCartItemId: identical(pendingCartItemId, _sentinel)
          ? this.pendingCartItemId
          : pendingCartItemId as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        isUpdating,
        errorMessage,
        infoMessage,
        pendingProductId,
        pendingCartItemId,
      ];
}
