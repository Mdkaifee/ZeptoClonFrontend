import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/features/orders/cubit/orders_cubit.dart';
import 'package:flutter_application_1/features/orders/cubit/orders_state.dart';
import 'package:flutter_application_1/features/orders/data/models/order_model.dart';

class YourOrdersScreen extends StatefulWidget {
  const YourOrdersScreen({
    super.key,
    required this.userId,
    this.initialOrder,
  });

  final String userId;
  final OrderModel? initialOrder;

  @override
  State<YourOrdersScreen> createState() => _YourOrdersScreenState();
}

class _YourOrdersScreenState extends State<YourOrdersScreen> {
  @override
  void initState() {
    super.initState();
    final ordersCubit = context.read<OrdersCubit>();
    ordersCubit.fetchOrders(widget.userId);
    if (widget.initialOrder != null) {
      ordersCubit.addOrderToState(widget.initialOrder!);
    }
  }

  Future<void> _refresh() async {
    await context.read<OrdersCubit>().fetchOrders(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage ?? 'Failed to fetch orders',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final orders = state.orders;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt!.toLocal())
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.product.name)),
                    Text('x${item.quantity}'),
                    Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const Divider(),
            Text('Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}'),
            Text('Payment Status: ${order.paymentStatus}'),
            Text('Order Status: ${order.orderStatus}'),
            Text('Placed on: $date'),
          ],
        ),
      ),
    );
  }
}
