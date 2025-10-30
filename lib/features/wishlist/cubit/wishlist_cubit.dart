import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_1/features/wishlist/cubit/wishlist_state.dart';
import 'package:flutter_application_1/features/wishlist/data/repositories/wishlist_repository.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({required WishlistRepository wishlistRepository})
      : _wishlistRepository = wishlistRepository,
        super(const WishlistState());

  final WishlistRepository _wishlistRepository;

  String? _currentUserId;

  Future<void> loadWishlist(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.status == WishlistStatus.success &&
        _currentUserId == userId) {
      return;
    }

    _currentUserId = userId;
    emit(
      state.copyWith(
        status: WishlistStatus.loading,
        errorMessage: null,
        infoMessage: null,
        pendingProductId: null,
      ),
    );

    try {
      final products = await _wishlistRepository.fetchWishlist(userId);
      emit(
        state.copyWith(
          status: WishlistStatus.success,
          products: products,
          isUpdating: false,
          errorMessage: null,
          infoMessage: null,
          pendingProductId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: WishlistStatus.failure,
          products: const <ProductModel>[],
          isUpdating: false,
          errorMessage: error.toString(),
          infoMessage: null,
          pendingProductId: null,
        ),
      );
    }
  }

  Future<void> refresh(String userId) {
    return loadWishlist(userId, forceRefresh: true);
  }

  Future<void> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    final isFavourite = state.productIds.contains(productId);
    if (isFavourite) {
      await removeFromWishlist(userId: userId, productId: productId);
    } else {
      await addToWishlist(userId: userId, productId: productId);
    }
  }

  Future<void> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    _currentUserId = userId;
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        infoMessage: null,
        pendingProductId: productId,
      ),
    );

    try {
      final result = await _wishlistRepository.addToWishlist(
        userId: userId,
        productId: productId,
      );
      emit(
        state.copyWith(
          status: WishlistStatus.success,
          products: result.products,
          isUpdating: false,
          errorMessage: null,
          infoMessage: result.message,
          pendingProductId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          infoMessage: null,
          pendingProductId: null,
        ),
      );
    }
  }

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    _currentUserId = userId;
    emit(
      state.copyWith(
        isUpdating: true,
        errorMessage: null,
        infoMessage: null,
        pendingProductId: productId,
      ),
    );

    try {
      final result = await _wishlistRepository.removeFromWishlist(
        userId: userId,
        productId: productId,
      );
      emit(
        state.copyWith(
          status: WishlistStatus.success,
          products: result.products,
          isUpdating: false,
          errorMessage: null,
          infoMessage: result.message,
          pendingProductId: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: error.toString(),
          infoMessage: null,
          pendingProductId: null,
        ),
      );
    }
  }

  void clear() {
    _currentUserId = null;
    emit(const WishlistState());
  }

  String? get currentUserId => _currentUserId;
}
