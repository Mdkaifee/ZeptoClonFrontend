import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  final List<dynamic> cartItems;
  final int totalItems;
  final double grandTotal;
  final String paymentStatus;  // New field for payment status
  final String itemStatus;     // New field for item status

  const OrdersScreen({
    Key? key,
    required this.cartItems,
    required this.totalItems,
    required this.grandTotal,
    required this.paymentStatus,
    required this.itemStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final product = item['product'];
                  final int quantity = item['quantity'];
                  final double price = (product['price'] as num).toDouble();
                  final double totalPrice = price * quantity;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Product: ${product['name']}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Quantity: $quantity"),
                          const SizedBox(height: 4),
                          Text("Price per item: ₹${price.toStringAsFixed(2)}"),
                          Text("Total price: ₹${totalPrice.toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5),
            Text("Total items: $totalItems",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Grand Total: ₹${grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ------------------- Payment Status -------------------
            Text("Payment Status: $paymentStatus",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // ------------------- Item Status -------------------
            Text("Item Status: $itemStatus",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
