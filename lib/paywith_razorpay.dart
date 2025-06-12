import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'your_orders_screen.dart';  // Import YourOrdersScreen
class PayWithRazorpayScreen extends StatefulWidget {
  final double grandTotal;
  final int totalItems;
  final List<dynamic> cartItems;

  const PayWithRazorpayScreen({
    Key? key,
    required this.grandTotal,
    required this.totalItems,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<PayWithRazorpayScreen> createState() => _PayWithRazorpayScreenState();
}

class _PayWithRazorpayScreenState extends State<PayWithRazorpayScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Listen for payment success and failure (including cancellations)
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError); // For failures and cancellations
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();  // Clean up Razorpay instance
  }
  // Handle payment success
void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  print("Payment Success: ${response.paymentId}");

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  try {
    // Create order in backend with payment status 'Paid'
    var orderResponse = await http.post(
      Uri.parse('http://192.168.0.129:5000/api/orders/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'cartItems': widget.cartItems,
        'totalAmount': widget.grandTotal,
        'paymentStatus': 'Paid',
        'orderStatus': 'Ordered'
      }),
    );

    if (orderResponse.statusCode == 201) {
      print("🟢 [Frontend] Order created successfully after payment success");

      // Clear cart items using API
      await _clearCartItems(userId!);
 // Show the success dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) {
          return const AlertDialog(
            title: Text("Order Successful!"),
            content: Text(
              "Your order will be delivered shortly. Thank you for choosing QuickBasket.",
            ),
          );
        },
      );

      // Wait for 2 seconds before navigating
      await Future.delayed(const Duration(seconds: 2));

      // Close dialog explicitly before navigating
      Navigator.pop(context);
      // Navigate to YourOrdersScreen after creating order successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const YourOrdersScreen(isFromPayWithRazorpay: true), 
        ),
      );
    } else {
      print("🔴 [Frontend] Failed to create order after payment. Response: ${orderResponse.body}");
    }
  } catch (e) {
    print("🔴 [Frontend] Exception during order creation after payment success: $e");
  }
}

// Add the _clearCartItems method to your PayWithRazorpayScreen:
Future<void> _clearCartItems(String userId) async {
  var url = Uri.parse('http://192.168.0.129:5000/api/cart/clear/$userId');

  try {
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      print("🟢 Cart cleared successfully.");
    } else {
      print("🔴 Failed to clear the cart.");
    }
  } catch (e) {
    print("🔴 Error clearing cart: $e");
  }
}

  // Handle payment error (including cancellations)
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failure or Canceled: ${response.message}");
    // Show an error or cancellation message to the user
  }

Future<String> _createOrderOnBackend() async {
  final url = 'http://192.168.0.129:5000/api/payment/create-order';

  final amountInPaise = (widget.grandTotal * 100).toInt();
  print("🔵 [Frontend] Initiating backend order creation with amount: $amountInPaise paise");

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  print("🔵 [Frontend] Fetched User ID from SharedPreferences: $userId");

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInPaise,
        'userId': userId,  // Pass the userId here
      }),
    );

    print("🟡 [Frontend] Received response status: ${response.statusCode}");
    print("🟡 [Frontend] Response body: ${response.body}");

    if (response.statusCode == 200) {
      var orderData = json.decode(response.body);
      print("🟢 [Frontend] Order ID from backend: ${orderData['orderId']}");

      return orderData['orderId'];
    } else {
      print("🔴 [Frontend] Failed to create Razorpay order. Response: ${response.body}");
      throw Exception('Failed to create Razorpay order');
    }
  } catch (e) {
    print("🔴 [Frontend] Exception during order creation: $e");
    throw Exception('Failed to create Razorpay order');
  }
}
  // Function to initiate Razorpay payment
  void _initiateRazorpayPayment() async {
    try {
      // Step 1: Create order on backend and get orderId
      String orderId = await _createOrderOnBackend();

      var options = {
  'key': 'rzp_test_eR5i8vZrGKVnEB',  // Your Razorpay key_id
  'amount': (widget.grandTotal * 100).toInt().toString(),  // Amount in paise (integer)
  'name': 'Kaifee Quick Mart',
  'description': 'Purchase from Your Store',
  'order_id': orderId,  // Use the orderId received from the backend
  'prefill': {
    'contact': '7982472309',
    'email': 'mdkaifee8298@gmail.com',
  },
  'theme': {
    'color': '#00A859',
  },
};

      // Step 2: Open Razorpay payment gateway
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay with Razorpay"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Review Your Payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Total Items and Total Amount
            Text(
              "Items: ${widget.totalItems}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Total Amount: ₹${widget.grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(thickness: 1.5),

            // Spacer
            const Spacer(),

            // Pay Now Button
            ElevatedButton(
              onPressed: _initiateRazorpayPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, // Button background color
                minimumSize: const Size(double.infinity, 50), // Full width button
              ),
              child: const Text(
                "Pay Now",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
