import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';  // Import your HomeScreen here
import 'package:slide_to_act/slide_to_act.dart'; // 👈 Import this
import 'payment.dart';
class CartScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  final VoidCallback onCartChanged;

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.onCartChanged,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<dynamic> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems); // Make a mutable copy
  }

void updateQuantity(int index, int change) async {
  final cartItem = _cartItems[index];
  final cartItemId = cartItem['_id'];
  final productId = cartItem['product']['_id'];
  final newQuantity = cartItem['quantity'] + change;

  // Prevent negative quantities
  if (newQuantity < 0) return;

  final url = Uri.parse('http://192.168.0.129:5000/api/cart/update');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'cartItemId': cartItemId,
      'quantityChange': change,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    print("Cart updated: $responseBody");

    setState(() {
      if (responseBody['message'] == "Item removed from cart" || newQuantity == 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = newQuantity;
      }
    });

    widget.onCartChanged(); // 🔁 Notify HomeScreen to refresh badge
  } else {
    print("Failed to update cart: ${response.body}");
  }
}

  int get totalItems =>
      _cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

  double get grandTotal => _cartItems.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          ((item['product']['price'] as num).toDouble() *
              (item['quantity'] as int)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text(
                "🛒 No items in your cart",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
            
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "--- Cart Summary ---",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        final product = item['product'];
                        final int quantity = item['quantity'];
                        final double price =
                            (product['price'] as num).toDouble();
                        final double totalPrice = price * quantity;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Product: ${product['name']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "Quantity: ${product['quantity']['value']} ${product['quantity']['unit']}"),
                                const SizedBox(height: 4),
                                Image.network(
                                  product['image'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "Price per item: \₹${price.toStringAsFixed(2)}"),
                                Text("Total price: \₹${totalPrice.toStringAsFixed(2)}"),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          const Icon(Icons.remove_circle_outline),
                                      onPressed: () =>
                                          updateQuantity(index, -1),
                                    ),
                                    Text('$quantity'),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () =>
                                          updateQuantity(index, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                 Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'Missed something?',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              token: '', // <- Replace with actual token if available
              user: {},  // <- Replace with actual user map
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Add More Items",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  ],
),
             const Divider(thickness: 1.5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side: Totals
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total items in cart: $totalItems",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "Grand total price: \₹${grandTotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Right side: Slide to Pay
                Container(
  width: 200,
  height: 60,
 child: SlideAction(
  onSubmit: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentOptionScreen(
          cartItems: _cartItems,
          totalItems: totalItems,
          grandTotal: grandTotal,
        ),
      ),
    );
  },
  text: "         Slide to Pay",
  textStyle: const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  outerColor: Colors.green.shade700,
  innerColor: Colors.white,
  elevation: 3,
  sliderButtonIcon: const Icon(
    Icons.payment,
    size: 20, // 🔽 reduced size to prevent covering text
    color: Colors.green,
  ),
  sliderRotate: false, // Prevents unnecessary icon rotation
  borderRadius: 16,
  height: 56,
  alignment: Alignment.centerRight, // Optional: aligns the button nicely
),

),
]),
                ],
              ),
            ),
    );
  }
}
