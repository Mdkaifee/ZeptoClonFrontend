import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/cart/data/repositories/cart_repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(const CartState()) {
    on<CartRequested>(_onCartRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemQuantityChanged>(_onCartItemQuantityChanged);
    on<CartCleared>(_onCartCleared);
  }

  final CartRepository _cartRepository;

  Future<void> _onCartRequested(
    CartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading, errorMessage: null));
    try {
      final items = await _cartRepository.fetchCart(event.userId);
      emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        infoMessage: null,
        pendingProductId: event.productId,
        pendingCartItemId: null,
      ),
    );
    try {
      final result = await _cartRepository.addToCart(
        userId: event.userId,
        productId: event.productId,
        quantity: event.quantity,
      );
      final updatedItems = await _cartRepository.fetchCart(event.userId);
      emit(
        state.copyWith(
          status: CartStatus.success,
          items: updatedItems,
          isUpdating: false,
          infoMessage: result.message,
          pendingProductId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          pendingProductId: null,
        ),
      );
    }
  }

  Future<void> _onCartItemQuantityChanged(
    CartItemQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        infoMessage: null,
        pendingCartItemId: event.cartItemId,
        pendingProductId: null,
      ),
    );
    try {
      final result = await _cartRepository.updateQuantity(
        cartItemId: event.cartItemId,
        quantityChange: event.quantityChange,
      );
      final updatedItems = await _cartRepository.fetchCart(event.userId);
      emit(
        state.copyWith(
          status: CartStatus.success,
          items: updatedItems,
          isUpdating: false,
          infoMessage: result.message,
          pendingCartItemId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          pendingCartItemId: null,
        ),
      );
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        infoMessage: null,
        pendingCartItemId: null,
        pendingProductId: null,
      ),
    );
    try {
      await _cartRepository.clearCart(event.userId);
      emit(
        state.copyWith(
          status: CartStatus.success,
          items: const <CartItemModel>[],
          isUpdating: false,
          infoMessage: 'Cart cleared',
          pendingProductId: null,
          pendingCartItemId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          pendingProductId: null,
          pendingCartItemId: null,
        ),
      );
    }
  }
}
