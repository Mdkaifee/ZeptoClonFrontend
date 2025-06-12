import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayWithRazorpayScreen extends StatefulWidget {
  final double grandTotal;
  final int totalItems;

  const PayWithRazorpayScreen({
    Key? key,
    required this.grandTotal,
    required this.totalItems,
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
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    // Implement logic to confirm payment and complete the order
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

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInPaise,
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
  'name': 'Payment for Your Order',
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
