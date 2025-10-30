import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/cart.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_1/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:flutter_application_1/features/wishlist/cubit/wishlist_state.dart';
import 'package:flutter_application_1/register_page.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key, required this.userId});

  final String userId;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<WishlistCubit>()
          .loadWishlist(widget.userId, forceRefresh: true);

      final authState = context.read<AuthBloc>().state;
      final cartBloc = context.read<CartBloc>();
      if (authState.status == AuthStatus.authenticated &&
          authState.user.isNotEmpty &&
          cartBloc.state.status == CartStatus.initial) {
        cartBloc.add(CartRequested(userId: authState.user.id));
      }
    });
  }

  Future<void> _refresh() {
    return context.read<WishlistCubit>().refresh(widget.userId);
  }

  void _toggleWishlist(ProductModel product) {
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

  void _addToCart(ProductModel product) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    if (authState.status != AuthStatus.authenticated || user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart')),
      );
      Navigator.pushReplacementNamed(context, RegisterPage.routeName);
      return;
    }

    context.read<CartBloc>().add(
          CartItemAdded(
            userId: user.id,
            productId: product.id,
          ),
        );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartBloc>(),
          child: const CartScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          previous.infoMessage != current.infoMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.infoMessage != null && state.infoMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.infoMessage!)),
          );
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Wishlist'),
          actions: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final totalItems = cartState.totalItems;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _openCart,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: 'View Cart',
                      ),
                      if (totalItems > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              totalItems > 99 ? '99+' : '$totalItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, wishlistState) {
            if (wishlistState.status == WishlistStatus.loading &&
                wishlistState.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (wishlistState.status == WishlistStatus.failure &&
                wishlistState.products.isEmpty) {
              final message =
                  wishlistState.errorMessage ?? 'Failed to load wishlist items.';
              return _WishlistErrorView(
                message: message,
                onRetry: () => _refresh(),
              );
            }

            if (wishlistState.products.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Your wishlist is empty.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: wishlistState.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = wishlistState.products[index];
                      final isWishlistUpdating = wishlistState.isUpdating &&
                          wishlistState.pendingProductId == product.id;
                      final isInCart = cartState.items.any(
                        (item) => item.product.id == product.id,
                      );
                      final isAddingToCart = cartState.isUpdating &&
                          cartState.pendingProductId == product.id;

                      return _WishlistItemCard(
                        product: product,
                        isWishlistUpdating: isWishlistUpdating,
                        isInCart: isInCart,
                        isAddingToCart: isAddingToCart,
                        onAddToCart: () => _addToCart(product),
                        onRemove: () => _toggleWishlist(product),
                        onViewCart: _openCart,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({
    required this.product,
    required this.isWishlistUpdating,
    required this.isInCart,
    required this.isAddingToCart,
    required this.onAddToCart,
    required this.onRemove,
    required this.onViewCart,
  });

  final ProductModel product;
  final bool isWishlistUpdating;
  final bool isInCart;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    final description = product.description ?? '';
    final quantity = product.formattedQuantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WishlistImage(imageUrl: product.imageUrl),
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
                            fontSize: 16,
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
                        onPressed: isWishlistUpdating ? null : onRemove,
                        icon: isWishlistUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              ),
                        tooltip: 'Remove from wishlist',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (quantity.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Quantity: $quantity'),
                  ],
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: isInCart
                        ? OutlinedButton.icon(
                            onPressed: onViewCart,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('View Cart'),
                          )
                        : ElevatedButton.icon(
                            onPressed: isAddingToCart ? null : onAddToCart,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: isAddingToCart
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Add to Cart'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistImage extends StatelessWidget {
  const _WishlistImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const double size = 72;
    if ((imageUrl ?? '').isEmpty) {
      return const _WishlistPlaceholder(size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _WishlistPlaceholder(size: size),
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

class _WishlistPlaceholder extends StatelessWidget {
  const _WishlistPlaceholder({required this.size});

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
      child: const Icon(Icons.favorite_border),
    );
  }
}

class _WishlistErrorView extends StatelessWidget {
  const _WishlistErrorView({
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
