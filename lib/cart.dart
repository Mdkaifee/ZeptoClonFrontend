import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/features/auth/bloc/auth_state.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';

import 'payment.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    if (authState.status != AuthStatus.authenticated || user.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: const Center(
          child: Text('Login to view your cart'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage ?? 'Failed to load cart',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'No items in your cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final itemUpdating = state.isUpdating &&
                        state.pendingCartItemId == item.id;
                    return _CartItemCard(
                      item: item,
                      isUpdating: itemUpdating,
                      onIncrease: () {
                        context.read<CartBloc>().add(
                              CartItemQuantityChanged(
                                userId: user.id,
                                cartItemId: item.id,
                                quantityChange: 1,
                              ),
                            );
                      },
                      onDecrease: () {
                        context.read<CartBloc>().add(
                              CartItemQuantityChanged(
                                userId: user.id,
                                cartItemId: item.id,
                                quantityChange: -1,
                              ),
                            );
                      },
                    );
                  },
                ),
              ),
              _CartSummary(
                totalItems: state.totalItems,
                totalAmount: state.totalAmount,
                isUpdating: state.isUpdating,
                onCheckout: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<CartBloc>()),
                          BlocProvider.value(value: context.read<CheckoutCubit>()),
                        ],
                        child: PaymentOptionScreen(user: user),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.isUpdating,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.product.formattedQuantity.isNotEmpty)
              Text('Quantity: ${item.product.formattedQuantity}'),
            const SizedBox(height: 8),
            Text('Price: ₹${item.product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: isUpdating ? null : onDecrease,
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: isUpdating ? null : onIncrease,
                    ),
                  ],
                ),
                Text(
                  'Subtotal: ₹${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.totalItems,
    required this.totalAmount,
    required this.isUpdating,
    required this.onCheckout,
  });

  final int totalItems;
  final double totalAmount;
  final bool isUpdating;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: const Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total items: $totalItems',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            'Grand total: ₹${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isUpdating ? null : onCheckout,
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
