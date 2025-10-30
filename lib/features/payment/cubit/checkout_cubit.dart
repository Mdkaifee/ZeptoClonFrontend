import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_1/features/cart/data/repositories/cart_repository.dart';
import 'package:flutter_application_1/features/orders/cubit/orders_cubit.dart';
import 'package:flutter_application_1/features/orders/data/models/order_model.dart';
import 'package:flutter_application_1/features/orders/data/repositories/order_repository.dart';
import 'package:flutter_application_1/features/payment/cubit/checkout_state.dart';
import 'package:flutter_application_1/features/payment/data/repositories/payment_repository.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required OrderRepository orderRepository,
    required CartRepository cartRepository,
    required PaymentRepository paymentRepository,
    OrdersCubit? ordersCubit,
  })  : _orderRepository = orderRepository,
        _cartRepository = cartRepository,
        _paymentRepository = paymentRepository,
        _ordersCubit = ordersCubit,
        super(const CheckoutState());

  final OrderRepository _orderRepository;
  final CartRepository _cartRepository;
  final PaymentRepository _paymentRepository;
  final OrdersCubit? _ordersCubit;

  void selectMethod(String method) {
    emit(
      state.copyWith(
        selectedMethod: method,
        status: CheckoutStatus.selecting,
        errorMessage: null,
        infoMessage: null,
      ),
    );
  }

  void selectUpiApp(String appId) {
    emit(
      state.copyWith(
        selectedUpiApp: appId,
        selectedMethod: 'upi',
        status: CheckoutStatus.selecting,
      ),
    );
  }

  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double totalAmount,
    required String paymentStatus,
    String orderStatus = 'Ordered',
  }) async {
    emit(
      state.copyWith(
        status: CheckoutStatus.processing,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      final order = await _orderRepository.createOrder(
        userId: userId,
        cartItems: cartItems,
        totalAmount: totalAmount,
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
      );
      await _cartRepository.clearCart(userId);
      _ordersCubit?.addOrderToState(order);

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          lastOrder: order,
          infoMessage: 'Order placed successfully.',
        ),
      );
      return order;
    } catch (error) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<String> createRazorpayOrder({
    required double amount,
    required String userId,
  }) {
    return _paymentRepository.createRazorpayOrder(
      amount: amount,
      userId: userId,
    );
  }

  void resetCheckout() {
    emit(
      const CheckoutState(status: CheckoutStatus.initial),
    );
  }
}
