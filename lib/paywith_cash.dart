import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_state.dart';

import 'your_orders_screen.dart';

class PayWithCashScreen extends StatelessWidget {
  const PayWithCashScreen({
    super.key,
    required this.user,
    required this.cartItems,
    required this.amount,
  });

  final UserModel user;
  final List<CartItemModel> cartItems;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.status == CheckoutStatus.success && state.lastOrder != null) {
          context
              .read<CartBloc>()
              .add(CartRequested(userId: user.id));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => YourOrdersScreen(
                userId: user.id,
                initialOrder: state.lastOrder,
              ),
            ),
            (route) => route.isFirst,
          );
        } else if (state.status == CheckoutStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cash on Delivery')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount to be collected: ₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.quantity} item— ₹${item.product.price}'),
                        trailing: Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isProcessing
                        ? null
                        : () {
                            context.read<CheckoutCubit>().placeOrder(
                                  userId: user.id,
                                  cartItems: cartItems,
                                  totalAmount: amount,
                                  paymentStatus: 'COD',
                                );
                          },
                    child: state.isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm Order'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

