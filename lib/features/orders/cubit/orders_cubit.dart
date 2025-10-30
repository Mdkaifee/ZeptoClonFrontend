import 'package:bloc/bloc.dart';

import 'package:flutter_application_1/features/orders/cubit/orders_state.dart';
import 'package:flutter_application_1/features/orders/data/models/order_model.dart';
import 'package:flutter_application_1/features/orders/data/repositories/order_repository.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrdersState());

  final OrderRepository _orderRepository;

  Future<void> fetchOrders(String userId) async {
    emit(state.copyWith(status: OrdersStatus.loading, errorMessage: null));
    try {
      final orders = await _orderRepository.fetchOrders(userId);
      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void addOrderToState(OrderModel order) {
    final updated = [order, ...state.orders];
    emit(state.copyWith(orders: updated, status: OrdersStatus.success));
  }
}
