import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_state.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_state.dart';

import 'paywith_cash.dart';
import 'paywith_razorpay.dart';

class PaymentOptionScreen extends StatefulWidget {
  const PaymentOptionScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().resetCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Options')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return BlocBuilder<CheckoutCubit, CheckoutState>(
            builder: (context, checkoutState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review Your Order',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartState.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.product.name),
                              subtitle: Text(
                                '${item.quantity} × ₹ ${item.unitPrice.toStringAsFixed(2)}',
                              ),
                              trailing: Text(
                                '₹ ${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Total items: ${cartState.totalItems}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Grand total: ₹ ${cartState.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodTile(
                      title: 'Pay Online (Razorpay)',
                      value: 'razorpay',
                      groupValue: checkoutState.selectedMethod,
                      onSelected: context.read<CheckoutCubit>().selectMethod,
                    ),
                    _PaymentMethodTile(
                      title: 'Cash on Delivery',
                      value: 'cod',
                      groupValue: checkoutState.selectedMethod,
                      onSelected: context.read<CheckoutCubit>().selectMethod,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkoutState.isProcessing
                            ? null
                            : () => _handlePayment(
                                  context: context,
                                  checkoutState: checkoutState,
                                  cartState: cartState,
                                ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: checkoutState.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Proceed to Pay  ₹ ${cartState.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handlePayment({
    required BuildContext context,
    required CheckoutState checkoutState,
    required CartState cartState,
  }) {
    final checkoutCubit = context.read<CheckoutCubit>();
    switch (checkoutState.selectedMethod) {
      case 'razorpay':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<CartBloc>()),
                BlocProvider.value(value: checkoutCubit),
              ],
              child: PayWithRazorpayScreen(
                user: widget.user,
                amount: cartState.totalAmount,
                cartItems: cartState.items,
              ),
            ),
          ),
        );
        break;
      case 'cod':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<CartBloc>()),
                BlocProvider.value(value: checkoutCubit),
              ],
              child: PayWithCashScreen(
                user: widget.user,
                amount: cartState.totalAmount,
                cartItems: cartState.items,
              ),
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method.')),
        );
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (selected) {
          if (selected != null) {
            onSelected(selected);
          }
        },
        title: Text(title),
      ),
    );
  }
}
