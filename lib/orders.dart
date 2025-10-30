import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/orders/data/models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
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
              'Total items: ${order.items.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Grand total: ₹ ${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Payment Status: ${order.paymentStatus}'),
            Text('Order Status: ${order.orderStatus}'),
          ],
        ),
      ),
    );
  }
}
