import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'orders.dart';  // Import OrdersScreen
import 'package:fluttertoast/fluttertoast.dart';


class PayWithCashScreen extends StatefulWidget {
  final List<dynamic> cartItems;  // Add cartItems
  final int totalItems;
  final double grandTotal;


  const PayWithCashScreen({
    Key? key,
    required this.cartItems,
    required this.totalItems,
    required this.grandTotal,
  }) : super(key: key);

  @override
  State<PayWithCashScreen> createState() => _PayWithCashScreenState();
}

class _PayWithCashScreenState extends State<PayWithCashScreen> {
  bool _payWithCashSelected = false;


// Second declaration of _getUserId (duplicate)
Future<String?> _getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');  // Retrieve stored userId
  print("Fetched userId: $userId");  // Debugging log
  return userId;
}
Future<void> _createOrder(String userId) async {
  var url = Uri.parse('http://192.168.0.129:5000/api/orders');  // API URL to save the order

  // Prepare order data to be sent to API
  var orderData = {
    'userId': userId,
    'cartItems': widget.cartItems,
    'totalAmount': widget.grandTotal,
    'paymentStatus': 'COD',  // Cash on delivery
    'orderStatus': 'Ordered',
  };

  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = json.decode(response.body);
      Fluttertoast.showToast(
        msg: "Order placed successfully!",
        backgroundColor: Colors.green,
      );

      // Navigate to the Orders screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrdersScreen(
            cartItems: widget.cartItems,
            totalItems: widget.totalItems,
            grandTotal: widget.grandTotal,
            paymentStatus: 'COD',
            itemStatus: 'Ordered',
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to place the order.",
        backgroundColor: Colors.red,
      );
    }
  } catch (e) {
    print("Error placing order: $e");
    Fluttertoast.showToast(
      msg: "Error placing order. Please try again.",
      backgroundColor: Colors.red,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay on Delivery"),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Items: ${widget.totalItems}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Total Amount: ₹${widget.grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1.5, height: 30),

            // Cash Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.money),
              title: const Text("Cash / Pay on Delivery"),
              trailing: Radio<bool>(
                value: true,
                groupValue: _payWithCashSelected,
                onChanged: (value) {
                  setState(() {
                    _payWithCashSelected = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _payWithCashSelected = true;
                });
              },
            ),

            const SizedBox(height: 20),

            // Pay Button
            if (_payWithCashSelected)
             ElevatedButton(
  onPressed: () async {
    // Fetch userId from SharedPreferences
    final userId = await _getUserId();

    if (userId == null || userId.isEmpty) {
      // If userId is null, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // Show success modal dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Order Successful!"),
          content: Text(
            "Cash payment of ₹${widget.grandTotal.toStringAsFixed(2)} will be collected on delivery.",
          ),
        );
      },
    );

    // Wait for 2 seconds before navigating
    await Future.delayed(Duration(seconds: 2));

    // Close the dialog automatically
    Navigator.of(context).pop();

    // Call API to create the order
    await _createOrder(userId);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade700,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
  ),
  child: Text.rich(
    TextSpan(
      children: [
        const TextSpan(
          text: "Pay Amount with Cash  ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "₹${widget.grandTotal.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}
