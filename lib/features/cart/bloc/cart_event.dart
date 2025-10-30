import 'package:equatable/equatable.dart';

class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartRequested extends CartEvent {
  const CartRequested({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({
    required this.userId,
    required this.productId,
    this.quantity = 1,
  });

  final String userId;
  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [userId, productId, quantity];
}

class CartItemQuantityChanged extends CartEvent {
  const CartItemQuantityChanged({
    required this.userId,
    required this.cartItemId,
    required this.quantityChange,
  });

  final String userId;
  final String cartItemId;
  final int quantityChange;

  @override
  List<Object?> get props => [userId, cartItemId, quantityChange];
}

class CartCleared extends CartEvent {
  const CartCleared({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}
