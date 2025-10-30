import 'package:equatable/equatable.dart';

import 'package:flutter_application_1/features/orders/data/models/order_model.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const <OrderModel>[],
    this.errorMessage,
  });

  final OrdersStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderModel>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
