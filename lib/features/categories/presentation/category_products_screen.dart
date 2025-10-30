import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/categories/cubit/category_products_cubit.dart';
import 'package:flutter_application_1/features/categories/cubit/category_products_state.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_1/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:flutter_application_1/features/wishlist/cubit/wishlist_state.dart';
import 'package:flutter_application_1/register_page.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.onAddToCart,
  });

  final String category;
  final ValueChanged<String> onAddToCart;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<CategoryProductsCubit>()
        .fetchProducts(widget.category);
  }

  void _onWishlistTap(ProductModel product) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    if (authState.status != AuthStatus.authenticated || user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to manage wishlist')),
      );
      Navigator.pushReplacementNamed(context, RegisterPage.routeName);
      return;
    }

    context.read<WishlistCubit>().toggleWishlist(
          userId: user.id,
          productId: product.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
        builder: (context, state) {
          switch (state.status) {
            case CategoryProductsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case CategoryProductsStatus.failure:
              return _CategoryErrorView(
                message: state.errorMessage ?? 'Failed to load products.',
                onRetry: () => context
                    .read<CategoryProductsCubit>()
                    .fetchProducts(widget.category),
              );
            case CategoryProductsStatus.success:
              if (state.products.isEmpty) {
                return const Center(
                  child: Text('No products available for this category.'),
                );
              }
              return BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, wishlistState) {
                  final wishlistIds = wishlistState.productIds;
                  final pendingId = wishlistState.pendingProductId;
                  final isUpdating = wishlistState.isUpdating;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      final isFavorite = wishlistIds.contains(product.id);
                      final isWishlistUpdating =
                          isUpdating && pendingId == product.id;
                      return _CategoryProductCard(
                        product: product,
                        onAddToCart: () => widget.onAddToCart(product.id),
                        onToggleWishlist: () => _onWishlistTap(product),
                        isFavorite: isFavorite,
                        isWishlistUpdating: isWishlistUpdating,
                      );
                    },
                  );
                },
              );
            case CategoryProductsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _CategoryErrorView extends StatelessWidget {
  const _CategoryErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  const _CategoryProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.isFavorite,
    required this.isWishlistUpdating,
  });

  final ProductModel product;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final bool isFavorite;
  final bool isWishlistUpdating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(imageUrl: product.imageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 22,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(minHeight: 36, minWidth: 36),
                            onPressed:
                                isWishlistUpdating ? null : onToggleWishlist,
                            icon: isWishlistUpdating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.redAccent
                                        : Colors.grey,
                                  ),
                            tooltip: isFavorite
                                ? 'Remove from wishlist'
                                : 'Add to wishlist',
                          ),
                        ],
                      ),
                      if ((product.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (product.formattedQuantity.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Quantity: ${product.formattedQuantity}'),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '₹ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                CartItemModel? cartItem;
                for (final item in cartState.items) {
                  if (item.product.id == product.id) {
                    cartItem = item;
                    break;
                  }
                }

                if (cartItem == null) {
                  final isLoading = cartState.isUpdating &&
                      cartState.pendingProductId == product.id;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add to Cart'),
                    ),
                  );
                }

                final cartItemId = cartItem.id;
                final isUpdatingQuantity = cartState.isUpdating &&
                    cartState.pendingCartItemId == cartItemId;
                final user = context.read<AuthBloc>().state.user;
                final quantityText = '${cartItem.quantity}';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: isUpdatingQuantity
                                ? null
                                : () {
                                    if (user.isEmpty) return;
                                    context.read<CartBloc>().add(
                                          CartItemQuantityChanged(
                                            userId: user.id,
                                            cartItemId: cartItemId,
                                            quantityChange: -1,
                                          ),
                                        );
                                  },
                          ),
                          Text(
                            quantityText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: isUpdatingQuantity
                                ? null
                                : () {
                                    if (user.isEmpty) return;
                                    context.read<CartBloc>().add(
                                          CartItemQuantityChanged(
                                            userId: user.id,
                                            cartItemId: cartItemId,
                                            quantityChange: 1,
                                          ),
                                        );
                                  },
                          ),
                        ],
                      ),
                      if (isUpdatingQuantity)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const double size = 80;
    if ((imageUrl ?? '').isEmpty) {
      return _PlaceholderImage(size: size);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderImage(size: size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}




