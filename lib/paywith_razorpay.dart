import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:flutter_application_1/features/auth/data/models/user_model.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/bloc/cart_event.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_cubit.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_state.dart';

import 'your_orders_screen.dart';

class PayWithRazorpayScreen extends StatefulWidget {
  const PayWithRazorpayScreen({
    super.key,
    required this.user,
    required this.amount,
    required this.cartItems,
  });

  final UserModel user;
  final double amount;
  final List<CartItemModel> cartItems;

  @override
  State<PayWithRazorpayScreen> createState() => _PayWithRazorpayScreenState();
}

class _PayWithRazorpayScreenState extends State<PayWithRazorpayScreen> {
  late final Razorpay _razorpay;
  bool _paymentInitiated = false;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initiatePayment(BuildContext context) async {
    if (_paymentInitiated || _isConfirming) return;
    setState(() {
      _paymentInitiated = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final checkoutCubit = context.read<CheckoutCubit>();
      final orderId = await checkoutCubit.createRazorpayOrder(
        amount: widget.amount,
        userId: widget.user.id,
      );
      final options = {
        'key': 'rzp_test_eR5i8vZrGKVnEB',
        'amount': (widget.amount * 100).toInt().toString(),
        'name': 'Kaifee Quick Mart',
        'description': 'Order payment',
        'order_id': orderId,
        'prefill': {
          'contact': widget.user.mobile ?? '',
          'email': widget.user.email,
        },
        'theme': {'color': '#00A859'},
      };
      _razorpay.open(options);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to start payment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _paymentInitiated = false;
        });
      } else {
        _paymentInitiated = false;
      }
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (!_isConfirming) {
      setState(() {
        _isConfirming = true;
      });
    }

    final checkoutCubit = context.read<CheckoutCubit>();
    checkoutCubit
        .placeOrder(
          userId: widget.user.id,
          cartItems: widget.cartItems,
          totalAmount: widget.amount,
          paymentStatus: 'Paid',
        )
        .then((order) {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
      });
      context.read<CartBloc>().add(
            CartRequested(userId: widget.user.id),
          );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => YourOrdersScreen(
            userId: widget.user.id,
            initialOrder: order,
          ),
        ),
        (route) => route.isFirst,
      );
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm payment: $error')),
      );
    });
  }

  void _handleError(PaymentFailureResponse response) {
    if (!mounted) {
      return;
    }
    final fallback = _mapFailureMessage(response);
    setState(() {
      _paymentInitiated = false;
      _isConfirming = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(fallback)),
    );
  }

  String _mapFailureMessage(PaymentFailureResponse response) {
    final raw = response.message;
    if (_hasMeaningfulText(raw)) {
      return raw!.trim();
    }

    final extracted = _extractDescription(response.error);
    if (_hasMeaningfulText(extracted)) {
      return extracted!.trim();
    }

    return 'Payment cancelled';
  }

  String? _extractDescription(dynamic error) {
    if (error == null) {
      return null;
    }

    if (error is Map) {
      final nested = error['description'] ??
          (error['error'] is Map ? error['error']['description'] : null) ??
          (error['data'] is Map ? error['data']['description'] : null);
      if (_hasMeaningfulText(nested?.toString())) {
        return nested.toString();
      }
    }

    final text = error.toString();
    return _hasMeaningfulText(text) ? text : null;
  }

  bool _hasMeaningfulText(String? value) {
    if (value == null) {
      return false;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final lower = trimmed.toLowerCase();
    if (lower == 'undefined' || lower == 'null') {
      return false;
    }
    if (lower.contains('description: undefined') ||
        lower.contains('"description":"undefined"') ||
        lower.contains("'description':'undefined'")) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.status == CheckoutStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('Pay with Razorpay')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review Your Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Amount: ₹ ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                            '${item.quantity} × ₹ ${item.unitPrice.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            '₹ ${item.totalPrice.toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_paymentInitiated || _isConfirming)
                          ? null
                          : () => _initiatePayment(context),
                      child: _paymentInitiated
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isConfirming)
            IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Finalizing payment...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
